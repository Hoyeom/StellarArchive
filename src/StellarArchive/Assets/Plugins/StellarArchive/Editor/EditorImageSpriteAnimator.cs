using System.Collections;
using Unity.EditorCoroutines.Editor;
using UnityEditor;
using UnityEngine;

namespace StellarArchive
{
    [UnityEditor.CustomEditor(typeof(ImageSpriteAnimator))]
    public class EditorImageSpriteAnimator : UnityEditor.Editor
    {
        private EditorCoroutine _editorCoroutine;
        
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            if (Application.isPlaying)
                return;
            
            if (GUILayout.Button("Play"))
            {
                if (_editorCoroutine != null)
                    EditorCoroutineUtility.StopCoroutine(_editorCoroutine);
                _editorCoroutine = EditorCoroutineUtility.StartCoroutine(PlayAnimationRoutine(), this);
            }
            
            if (GUILayout.Button("Stop"))
            {
                if (_editorCoroutine != null)
                    EditorCoroutineUtility.StopCoroutine(_editorCoroutine);
            }
        }

        IEnumerator PlayAnimationRoutine()
        {
            var imageSpriteAnimator = (ImageSpriteAnimator)target;

            var delay = imageSpriteAnimator.GetDelay();
            var waitDelay = new EditorWaitForSeconds(delay);
            
            if (delay > 0)
            {
                while (true)
                {
                    yield return waitDelay;
                    imageSpriteAnimator.ChangeNextSprite();
                    EditorUtility.SetDirty(imageSpriteAnimator);
                }   
            }
        }
    }
}
