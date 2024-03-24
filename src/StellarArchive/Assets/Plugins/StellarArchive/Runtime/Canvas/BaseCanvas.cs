using System;
using System.Collections;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Canvas))]
[DisallowMultipleComponent]
public abstract class BaseCanvas : MonoBehaviour
{
    private Canvas _canvas;
    private CanvasScaler _canvasScaler;
    [SerializeField] private CanvasType _canvasType;
    public bool Fixed { get; private set; } = false;
    public CanvasType Type => _canvasType;

    public CanvasStatus Status { get; protected set; }

    internal delegate bool TryCloseHandler(BaseCanvas baseCanvas);
    internal delegate bool TryOpenHandler(BaseCanvas baseCanvas);
    internal event TryCloseHandler OnTryOpen; 
    internal event TryOpenHandler OnTryClose; 
    
    private void Awake()
    {
        _canvas = GetComponent<Canvas>();
        _canvasScaler = GetComponent<CanvasScaler>();
    }

    public void SetFixed(bool value)
    {
        Fixed = value;
    }

    public bool TryOpen()
    {
        if (OnTryOpen != null)
            return OnTryOpen.Invoke(this);
        return false;
    }
    
    public bool TryClose()
    {
        if (OnTryClose != null)
            return OnTryClose.Invoke(this);
        return false;
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
    
    internal void SetCamera(Camera cam)
    {
        _canvas.worldCamera = cam;
    }
    
#if UNITY_EDITOR
    private void OnValidate()
    {
        var getCurrentPrefabStage = UnityEditor.SceneManagement.PrefabStageUtility.GetCurrentPrefabStage();
        
        if(getCurrentPrefabStage == null) return;

        _canvasScaler = GetComponent<CanvasScaler>();
        _canvas = GetComponent<Canvas>();
        _canvasScaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        _canvasScaler.screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
        _canvasScaler.matchWidthOrHeight = .5f;
    }
#endif
}