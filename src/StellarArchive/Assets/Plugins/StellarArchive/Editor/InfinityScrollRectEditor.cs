using StellarArchive;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor.AnimatedValues;

namespace UnityEditor.UI
{
    [CustomEditor(typeof(InfinityScrollRect), true)]
    [CanEditMultipleObjects]
    public class InfinityScrollRectEditor : UnityEditor.Editor
    {
        SerializedProperty _content;
        SerializedProperty _horizontal;
        SerializedProperty _vertical;
        SerializedProperty _movementType;
        SerializedProperty _elasticity;
        SerializedProperty _inertia;
        SerializedProperty _decelerationRate;
        SerializedProperty _scrollSensitivity;
        SerializedProperty _viewport;
        SerializedProperty _horizontalScrollbar;
        SerializedProperty _verticalScrollbar;
        SerializedProperty _horizontalScrollbarVisibility;
        SerializedProperty _verticalScrollbarVisibility;
        SerializedProperty _horizontalScrollbarSpacing;
        SerializedProperty _verticalScrollbarSpacing;
        SerializedProperty _onValueChanged;
        AnimBool _showElasticity;
        AnimBool _showDecelerationRate;
        bool _viewportIsNotChild, _hScrollbarIsNotChild, _vScrollbarIsNotChild;
        static string HError = "For this visibility mode, the Viewport property and the Horizontal Scrollbar property both needs to be set to a Rect Transform that is a child to the Scroll Rect.";
        static string VError = "For this visibility mode, the Viewport property and the Vertical Scrollbar property both needs to be set to a Rect Transform that is a child to the Scroll Rect.";

        protected virtual void OnEnable()
        {
            _content               = serializedObject.FindProperty("_content");
            _horizontal            = serializedObject.FindProperty("_horizontal");
            _vertical              = serializedObject.FindProperty("_vertical");
            _movementType          = serializedObject.FindProperty("_movementType");
            _elasticity            = serializedObject.FindProperty("_elasticity");
            _inertia               = serializedObject.FindProperty("_inertia");
            _decelerationRate      = serializedObject.FindProperty("_decelerationRate");
            _scrollSensitivity     = serializedObject.FindProperty("_scrollSensitivity");
            _viewport              = serializedObject.FindProperty("_viewport");
            _horizontalScrollbar   = serializedObject.FindProperty("_horizontalScrollbar");
            _verticalScrollbar     = serializedObject.FindProperty("_verticalScrollbar");
            _horizontalScrollbarVisibility = serializedObject.FindProperty("_horizontalScrollbarVisibility");
            _verticalScrollbarVisibility   = serializedObject.FindProperty("_verticalScrollbarVisibility");
            _horizontalScrollbarSpacing    = serializedObject.FindProperty("_horizontalScrollbarSpacing");
            _verticalScrollbarSpacing      = serializedObject.FindProperty("_verticalScrollbarSpacing");
            _onValueChanged        = serializedObject.FindProperty("_onValueChanged");

            _showElasticity = new AnimBool(Repaint);
            _showDecelerationRate = new AnimBool(Repaint);
            SetAnimBools(true);
        }

        protected virtual void OnDisable()
        {
            _showElasticity.valueChanged.RemoveListener(Repaint);
            _showDecelerationRate.valueChanged.RemoveListener(Repaint);
        }

        void SetAnimBools(bool instant)
        {
            SetAnimBool(_showElasticity, !_movementType.hasMultipleDifferentValues && _movementType.enumValueIndex == (int)InfinityScrollRect.MovementType.Elastic, instant);
            SetAnimBool(_showDecelerationRate, !_inertia.hasMultipleDifferentValues && _inertia.boolValue == true, instant);
        }

        void SetAnimBool(AnimBool a, bool value, bool instant)
        {
            if (instant)
                a.value = value;
            else
                a.target = value;
        }

        void CalculateCachedValues()
        {
            _viewportIsNotChild = false;
            _hScrollbarIsNotChild = false;
            _vScrollbarIsNotChild = false;
            if (targets.Length == 1)
            {
                Transform transform = ((InfinityScrollRect)target).transform;
                if (_viewport.objectReferenceValue == null || ((RectTransform)_viewport.objectReferenceValue).transform.parent != transform)
                    _viewportIsNotChild = true;
                if (_horizontalScrollbar.objectReferenceValue == null || ((Scrollbar)_horizontalScrollbar.objectReferenceValue).transform.parent != transform)
                    _hScrollbarIsNotChild = true;
                if (_verticalScrollbar.objectReferenceValue == null || ((Scrollbar)_verticalScrollbar.objectReferenceValue).transform.parent != transform)
                    _vScrollbarIsNotChild = true;
            }
        }

        public override void OnInspectorGUI()
        {
            SetAnimBools(false);

            serializedObject.Update();
            // Once we have a reliable way to know if the object changed, only re-cache in that case.
            CalculateCachedValues();

            EditorGUILayout.PropertyField(_content);

            EditorGUILayout.PropertyField(_horizontal);
            EditorGUILayout.PropertyField(_vertical);

            EditorGUILayout.PropertyField(_movementType);
            if (EditorGUILayout.BeginFadeGroup(_showElasticity.faded))
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(_elasticity);
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFadeGroup();

            EditorGUILayout.PropertyField(_inertia);
            if (EditorGUILayout.BeginFadeGroup(_showDecelerationRate.faded))
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(_decelerationRate);
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFadeGroup();

            EditorGUILayout.PropertyField(_scrollSensitivity);

            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(_viewport);

            EditorGUILayout.PropertyField(_horizontalScrollbar);
            if (_horizontalScrollbar.objectReferenceValue && !_horizontalScrollbar.hasMultipleDifferentValues)
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(_horizontalScrollbarVisibility, EditorGUIUtility.TrTextContent("Visibility"));

                if ((InfinityScrollRect.ScrollbarVisibility)_horizontalScrollbarVisibility.enumValueIndex == InfinityScrollRect.ScrollbarVisibility.AutoHideAndExpandViewport
                    && !_horizontalScrollbarVisibility.hasMultipleDifferentValues)
                {
                    if (_viewportIsNotChild || _hScrollbarIsNotChild)
                        EditorGUILayout.HelpBox(HError, MessageType.Error);
                    EditorGUILayout.PropertyField(_horizontalScrollbarSpacing, EditorGUIUtility.TrTextContent("Spacing"));
                }

                EditorGUI.indentLevel--;
            }

            EditorGUILayout.PropertyField(_verticalScrollbar);
            if (_verticalScrollbar.objectReferenceValue && !_verticalScrollbar.hasMultipleDifferentValues)
            {
                EditorGUI.indentLevel++;
                EditorGUILayout.PropertyField(_verticalScrollbarVisibility, EditorGUIUtility.TrTextContent("Visibility"));

                if ((InfinityScrollRect.ScrollbarVisibility)_verticalScrollbarVisibility.enumValueIndex == InfinityScrollRect.ScrollbarVisibility.AutoHideAndExpandViewport
                    && !_verticalScrollbarVisibility.hasMultipleDifferentValues)
                {
                    if (_viewportIsNotChild || _vScrollbarIsNotChild)
                        EditorGUILayout.HelpBox(VError, MessageType.Error);
                    EditorGUILayout.PropertyField(_verticalScrollbarSpacing, EditorGUIUtility.TrTextContent("Spacing"));
                }

                EditorGUI.indentLevel--;
            }

            EditorGUILayout.Space();

            EditorGUILayout.PropertyField(_onValueChanged);

            serializedObject.ApplyModifiedProperties();
        }
    }
}
