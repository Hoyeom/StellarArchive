using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace StellarArchive
{
    [RequireComponent(typeof(Canvas))]
    [DisallowMultipleComponent]
    public abstract class BaseCanvas : UIBehaviour
    {
        private Canvas _canvas;
        private CanvasScaler _canvasScaler;

        private string _key;
        private IActivationHandler _activationHandler;
        public bool Fixed { get; private set; } = false;

        public CanvasStatus Status { get; protected set; }

        protected override void Awake()
        {
            _canvas = GetComponent<Canvas>();
            _canvasScaler = GetComponent<CanvasScaler>();
            _key = GetType().Name;
        }

        public void SetFixed(bool value)
        {
            Fixed = value;
        }

        public async UniTask<bool> TryOpenAsync()
        {
            return await _activationHandler.OnTryOpenAsync(_key);
        }

        public async UniTask<bool> TryCloseAsync()
        {
            return await _activationHandler.OnTryCloseAsync(_key);
        }

        internal void Open()
        {
            _canvas.enabled = true;
            Status = CanvasStatus.Open;
        }

        internal void Close()
        {
            _canvas.enabled = false;
            Status = CanvasStatus.Close;
        }

        public void TryOpenAsyncForget(string canvasName = null)
        {
            _activationHandler.OnTryOpenAsync(string.IsNullOrWhiteSpace(canvasName) ? _key : canvasName);
        }

        public void TryCloseAsyncForget()
        {
            _activationHandler.OnTryCloseAsync(_key);
        }

        internal async virtual UniTaskVoid OpenAsync()
        {
            _canvas.enabled = true;
            Status = CanvasStatus.Open;
        }

        internal async virtual UniTaskVoid CloseAsync()
        {
            _canvas.enabled = false;
            Status = CanvasStatus.Close;
        }

        internal void SetRenderMode(RenderMode renderMode)
        {
            _canvas.renderMode = renderMode;
        }

        internal void SetCamera(Camera cam)
        {
            _canvas.worldCamera = cam;
        }

        internal void SetOrder(int order)
        {
            _canvas.sortingOrder = order;
        }

        internal void Setup(IActivationHandler activationHandler)
        {
            _activationHandler = activationHandler;
        }

#if UNITY_EDITOR
        protected override void OnValidate()
        {
            var getCurrentPrefabStage = UnityEditor.SceneManagement.PrefabStageUtility.GetCurrentPrefabStage();

            if (getCurrentPrefabStage == null) return;

            _canvasScaler = GetComponent<CanvasScaler>();
            _canvas = GetComponent<Canvas>();
            _canvasScaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            _canvasScaler.screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
            // _canvasScaler.matchWidthOrHeight = 1f;
        }
#endif

    }
}