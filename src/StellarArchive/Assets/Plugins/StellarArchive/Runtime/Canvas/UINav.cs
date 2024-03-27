using System;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.EventSystems;

namespace StellarArchive
{
    public class UINav : IActivationHandler
    {
        public delegate void SetupHandler<T>(T baseCanvas) where T : BaseCanvas;

        private readonly Dictionary<string, BaseCanvas> _cachedCanvas = new Dictionary<string, BaseCanvas>();
        private readonly Stack<BaseCanvas> _canvasStack = new Stack<BaseCanvas>();

        private readonly Dictionary<string, SortedSet<AccessCondition>> _accessConditionsMap =
            new Dictionary<string, SortedSet<AccessCondition>>();

        private readonly Dictionary<string, object> _setupMap = new Dictionary<string, object>();
        private readonly HashSet<string> _canvasesInSetup = new HashSet<string>();

        public UINav()
        {

        }

        public void RegisterSetup<T>(SetupHandler<T> setup) where T : BaseCanvas
        {
            var key = typeof(T).Name;
            _setupMap.Add(key, setup);
        }

        public void RegisterAccessCondition<T>(AccessCondition accessCondition) where T : BaseCanvas
        {
            var key = typeof(T).Name;
            RegisterAccessCondition(key, accessCondition);
        }

        private void RegisterAccessCondition(string key, AccessCondition accessCondition)
        {
            if (!_accessConditionsMap.ContainsKey(key))
                _accessConditionsMap.Add(key, new SortedSet<AccessCondition>());
            _accessConditionsMap[key].Add(accessCondition);
        }

        public async UniTask<T> GetAsync<T>() where T : BaseCanvas
        {
            var type = typeof(T);
            var key = type.Name;
            return await GetOrCreateCanvasAsync<T>(key);
        }

        private async UniTask<BaseCanvas> InstantiateCanvasAsync(string key)
        {
#if UNITY_EDITOR
            Debug.Log($"[InstantiateCanvasAsync] {key}");
#endif
            if (_cachedCanvas.ContainsKey(key))
                return _cachedCanvas[key];

            if (_canvasesInSetup.Contains(key))
            {
                await UniTask.WaitUntil(() => _cachedCanvas.ContainsKey(key));
                return _cachedCanvas[key];
            }

            _canvasesInSetup.Add(key);

            var handle = Addressables.InstantiateAsync(key);
            await handle;
            var gameObject = handle.Result;
            var canvas = gameObject.GetComponent<BaseCanvas>();
            Setup(key, canvas);
            _canvasesInSetup.Remove(key);
            return canvas;
        }

        private async UniTask<T> GetOrCreateCanvasAsync<T>(string key) where T : BaseCanvas
        {
            if (_cachedCanvas.TryGetValue(key, out var cachedCanvas))
            {
                return cachedCanvas as T;
            }

            var baseCanvas = await InstantiateCanvasAsync(key);
            return baseCanvas as T;
        }

        private void Setup<T>(string key, T canvas) where T : BaseCanvas
        {
            canvas.Close();
            canvas.SetCamera(Camera.main);
            canvas.Setup(this);
            if (_setupMap.TryGetValue(key, out var value) && value is SetupHandler<T> handler)
            {
                handler.Invoke(canvas);
            }

#if UNITY_EDITOR
            canvas.name = key;
#endif
            _setupMap.Remove(key);
            _cachedCanvas.Add(key, canvas);
        }

        async UniTask<bool> IActivationHandler.OnTryOpenAsync(string key)
        {
#if UNITY_EDITOR
            Debug.Log($"[TryOpen] {key}");
#endif
            if (_canvasesInSetup.Contains(key))
                return false;

            if (_accessConditionsMap.TryGetValue(key, out var conditions))
            {
                foreach (var condition in conditions)
                {
                    if (!condition.CanAccess())
                        return false;
                }
            }

            var canvas = await InstantiateCanvasAsync(key);

            if (canvas.Status is CanvasStatus.Open or CanvasStatus.Opening)
                return false;

            if (_canvasStack.TryPeek(out var result))
            {
                if (result.Fixed)
                {
                    return false;
                }
            }

            if (canvas is HamburgerCanvas hamburgerCanvas)
            {
                if (EventSystem.current.currentSelectedGameObject != null)
                {
                    var anchor = (RectTransform)EventSystem.current.currentSelectedGameObject.transform;
                    hamburgerCanvas.SetInitialPosition(anchor);
                }
            }
            
            canvas.SetOrder(_canvasStack.Count);
            canvas.OpenAsync().Forget();
            _canvasStack.Push(canvas);
            return true;
        }

        async UniTask<bool> IActivationHandler.OnTryCloseAsync(string key)
        {
#if UNITY_EDITOR
            Debug.Log($"[TryClose] {key}");
#endif
            if (_canvasesInSetup.Contains(key))
                return false;

            var canvas = _cachedCanvas[key];

            if (canvas.Status is CanvasStatus.Close or CanvasStatus.Closing)
                return false;

            if (canvas.Fixed)
                return false;

            _canvasStack.Pop();

            canvas.CloseAsync().Forget();
            return true;
        }


    }
}