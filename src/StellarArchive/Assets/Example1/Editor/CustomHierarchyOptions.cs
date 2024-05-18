using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

[InitializeOnLoad]
public class CustomHierarchyOptions
{
    private static readonly Dictionary<int, List<float>> PaddingsMap = new Dictionary<int, List<float>>();
    private const float IconSize = 14;
    private const float IconPadding = 4;

    private static readonly Dictionary<Type, Texture> IconContentTextureMap;
    
    static CustomHierarchyOptions()
    {
        IconContentTextureMap = new Dictionary<Type, Texture>()
        {
            { typeof(Camera), EditorGUIUtility.IconContent("Camera Icon").image },
            { typeof(AudioListener), EditorGUIUtility.IconContent("AudioListener Icon").image },
        };
        
        EditorApplication.hierarchyWindowItemOnGUI += HierarchyWindowItemOnGUI;
    }

    static void IconContent(int instanceId, Rect rect)
    {
        if (EditorUtility.InstanceIDToObject(instanceId) is GameObject gameObject)
        {
            var components = gameObject.GetComponents<Component>();
            
            foreach (var component in components.OrderBy(component => component.GetComponentIndex()))
            {
                var type = component.GetType();
                component.GetComponentIndex();       
                if(IconContentTextureMap.ContainsKey(type))
                    DrawIconContentButton(instanceId, rect, type);
            }
        }
    }
    
    static void HierarchyWindowItemOnGUI(int instanceId, Rect selectionRect)
    {
        if (instanceId < 0) return;
        if (EditorUtility.InstanceIDToObject(instanceId) is GameObject gameObject)
        {
            PaddingsMap.Clear();
            DrawActiveToggleButton(instanceId, selectionRect);
            DrawZoomInButton(instanceId, selectionRect);
            if(gameObject.TryGetComponent<Info>(out _))
                DrawInfoButton(instanceId, selectionRect);
            IconContent(instanceId, selectionRect);
        }
    }

    static Rect DrawRect(Vector2 position, float size)
    {
        return DrawRect(position.x, position.y, size);
    }
    
    static Rect DrawRect(float x, float y, float size)
    {
        return new Rect(x, y, size, size);
    }

    static void DrawButtonWitchToggle(int id, Vector2 position, float size)
    {
        DrawButtonWitchToggle(id, position.x, position.y, size);
    }
    
    static void DrawButtonWitchToggle(int id, float x,float y, float size)
    {
        GameObject gameObject = EditorUtility.InstanceIDToObject(id) as GameObject;
        if (gameObject)
        {
            Rect rect = DrawRect(x, y, size);
            gameObject.SetActive(GUI.Toggle(rect, gameObject.activeSelf, string.Empty));
        }
    }

    static void DrawButtonWitchTexture(Vector2 position, float size, Texture texture, Action action, GameObject gameObject, string tooltip = null)
    {
        DrawButtonWitchTexture(position.x, position.y, size, texture, action, gameObject, tooltip);
    }
    
    static void DrawButtonWitchTexture(float x, float y, float size, Texture texture, Action action, GameObject gameObject, string tooltip = null)
    {
        if (gameObject)
        {
            GUIStyle guiStyle = new GUIStyle();
            guiStyle.fixedHeight = 0;
            guiStyle.fixedWidth = 0;
            guiStyle.stretchHeight = true;
            guiStyle.stretchWidth = true;
            Rect rect = DrawRect(x, y, size);
            GUIContent guiContent = new GUIContent();
            guiContent.image = texture;
            guiContent.text = string.Empty;
            guiContent.tooltip = tooltip;
            bool isClicked = GUI.Button(rect, guiContent, guiStyle);
            if (isClicked)
            {
                action.Invoke();
            }
        }
    }

    static void DrawActiveToggleButton(int id, Rect rect)
    {
        float size = 16f;
        float padding = 2f;
        Vector2 position = GetNextPosition(id, rect, size, padding);
        DrawButtonWitchToggle(id, position, size);
    }

    static void DrawInfoButton(int id, Rect rect)
    {
        GameObject gameObject = EditorUtility.InstanceIDToObject(id) as GameObject;
        string tooltip = string.Empty;
        if (gameObject)
        {
            if (gameObject.TryGetComponent(out Info info))
                tooltip = info.description;
        }
        float size = IconSize;
        float padding = IconPadding;

        Vector2 position = GetNextPosition(id, rect, IconSize, padding);
        Texture texture = Resources.Load("Info") as Texture;

        DrawButtonWitchTexture(position, size, texture, () =>
        {
            
        }, gameObject, tooltip);
    }
    
    static void DrawZoomInButton(int id, Rect rect)
    {
        GameObject gameObject = EditorUtility.InstanceIDToObject(id) as GameObject;
        float size = IconSize;
        float padding = IconPadding;
        string tooltip = "Frame this game object";

        Vector2 position = GetNextPosition(id, rect, IconSize, padding);
        Texture texture = Resources.Load("Zoom_In") as Texture;

        DrawButtonWitchTexture(position, size, texture, () =>
        {
            Selection.activeGameObject = gameObject;
            SceneView.FrameLastActiveSceneView();
        }, gameObject, tooltip);
    }
    
    static void DrawIconContentButton(int id, Rect rect, Type type)
    {
        GameObject gameObject = EditorUtility.InstanceIDToObject(id) as GameObject;
        float size = IconSize;
        float padding = IconPadding;

        Vector2 position = GetNextPosition(id, rect, size, padding);

        Texture texture = IconContentTextureMap[type];
        
        DrawButtonWitchTexture(position, size, texture, () =>
        {
        }, gameObject);
    }
    
    static void AddInfoScriptToGameObject(int id)
    {
        GameObject gameObject = EditorUtility.InstanceIDToObject(id) as GameObject;
        if (gameObject)
        {
            if (!gameObject.TryGetComponent<Info>(out _))
            {
                gameObject.AddComponent<Info>();
            }
        }
    }
    
    static Vector2 GetNextPosition(int id, Rect rect, float size, float padding = 0)
    {
        float xPosition = rect.x + rect.width - size - padding;
        float yPosition = rect.y + (rect.height - size) / 2;

        PaddingsMap.TryAdd(id, new List<float>());
        foreach (var rightSize in PaddingsMap[id])
            xPosition -= rightSize;
        
        Vector2 position = new Vector2(xPosition, yPosition);
        PaddingsMap[id].Add(size + padding);
        
        return position;
    }
}