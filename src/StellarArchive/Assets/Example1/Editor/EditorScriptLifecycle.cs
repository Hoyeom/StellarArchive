using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class EditorScriptLifecycle : EditorWindow
{
    [MenuItem("Window/Editor Script Lifecycle")]
    public static void ShowWindow()
    {
        EditorWindow window = GetWindow(typeof(EditorScriptLifecycle));
        window.Show();
    }
    
    private void Awake()
    {
        Debug.Log("Awake() was called");
    }

    public void CreateGUI()
    {
        Debug.Log("CreateGUI() was called");
    }

    public void OnBecameVisible()
    {
        Debug.Log("OnBecameVisible() was called");
    }

    public void OnFocus()
    {
        Debug.Log("OnFocus() was called");
    }

    public void OnGUI()
    {
        Debug.Log("OnGUI() was called");
    }

    public void OnHierarchyChange()
    {
        Debug.Log("OnHierarchyChange() was called");
    }

    public void OnInspectorUpdate()
    {
        Debug.Log("OnInspectorUpdate() was called");
    }

    public void OnProjectChange()
    {
        Debug.Log("OnProjectChange() was called");
    }

    public void OnSelectionChange()
    {
        Debug.Log("OnSelectionChange() was called");
    }

    public void Update()
    {
        Debug.Log("Update() was called");
    }

    public void OnLostFocus()
    {
        Debug.Log("OnLostFocus() was called");
    }

    public void OnBecameInvisible()
    {
        Debug.Log("OnBecameInvisible() was called");
    }

    public void OnDestroy()
    {
        Debug.Log("OnDestroy() was called");
    }
}
