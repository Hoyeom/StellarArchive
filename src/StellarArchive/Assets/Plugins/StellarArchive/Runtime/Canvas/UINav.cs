using System;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.AddressableAssets;

public class UINav
{
    private readonly Dictionary<Type, BaseCanvas> _cachedCanvas = new Dictionary<Type, BaseCanvas>();
    private Stack<BaseCanvas> _popupCanvasStack = new Stack<BaseCanvas>();
    private Queue<BaseCanvas> _pendingPopupCanvasQueue = new Queue<BaseCanvas>();
    
    public UINav()
    {
        
    }

    public async UniTask<T> GetAsync<T>() where T : BaseCanvas
    {
        var type = typeof(T);
        return await GetOrCreateCanvasAsync<T>(type);
    }

    private async UniTask<T> GetOrCreateCanvasAsync<T>(Type key) where T : BaseCanvas
    {
        if (_cachedCanvas.TryGetValue(key, out var cachedCanvas))
        {
            return cachedCanvas as T;
        }
        
        var handle = Addressables.InstantiateAsync(key.Name);
        await handle;

        var gameObject = handle.Result;
        var canvas = gameObject.GetComponent<T>();
        Setup(canvas);
        
        return canvas;
    }

    private void Setup<T>(T baseCanvas) where T : BaseCanvas
    {
        baseCanvas.Close();
        baseCanvas.SetCamera(Camera.main);
        baseCanvas.OnTryClose += OnTryClose;
        baseCanvas.OnTryOpen += OnTryOpen;
        
        _cachedCanvas.Add(baseCanvas.GetType(), baseCanvas);
    }

    private bool OnTryOpen(BaseCanvas baseCanvas)
    {
#if UNITY_EDITOR
        Debug.Log($"[TryOpen] {baseCanvas.GetType().Name}");
#endif
        if (baseCanvas.Status is CanvasStatus.Open or CanvasStatus.Opening)
            return false;

        if (baseCanvas.Type is CanvasType.Popup)
        {
            if (_popupCanvasStack.TryPeek(out var result))
            {
                if (result.Fixed)
                {
                    if (!_pendingPopupCanvasQueue.Contains(baseCanvas))
                        _pendingPopupCanvasQueue.Enqueue(baseCanvas);
                    return false;
                }
            }
        
            _popupCanvasStack.Push(baseCanvas);  
        }
        

        baseCanvas.OpenAsync().Forget();
        return true;
    }
    
    private bool OnTryClose(BaseCanvas baseCanvas)
    {
#if UNITY_EDITOR
        Debug.Log($"[TryClose] {baseCanvas.GetType().Name}");
#endif
        if (baseCanvas.Status is CanvasStatus.Close or CanvasStatus.Closing)
            return false;
        
        if (baseCanvas.Fixed)
            return false;

        if (baseCanvas.Type is CanvasType.Popup)
        {
            if (_popupCanvasStack.TryPeek(out var result) && !result.Equals(baseCanvas))
                return false;
         
            if (_pendingPopupCanvasQueue.TryDequeue(out result))
            {
                result.TryOpen();
            }
            
            _popupCanvasStack.Pop();
        }
        
        
        baseCanvas.CloseAsync().Forget();
        return true;
    }
}