using System;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.AddressableAssets;

public class NavCanvas
{
    private readonly Dictionary<Type, BaseCanvas> _cachedCanvas = new Dictionary<Type, BaseCanvas>();

    public NavCanvas()
    {
        
    }

    public async UniTask<T> GetAsync<T>() where T : BaseCanvas
    {
        var type = typeof(T);
        return await GetOrCreateCanvasAsync<T>(type);
    }

    private async UniTask<T> GetOrCreateCanvasAsync<T>(Type type) where T : BaseCanvas
    {
        if (_cachedCanvas.TryGetValue(type, out var cached))
        {
            return cached as T;
        }
        
        var handle = Addressables.InstantiateAsync(type.Name);
        await handle;

        var gameObject = handle.Result;
        var canvas = gameObject.GetComponent<T>();

        _cachedCanvas.Add(type, canvas);
        return canvas;
    }

}