// ReSharper disable CheckNamespace

using System.Threading;
using UnityEngine;
using UnityEngine.SceneManagement;

#if STELLARARCHIVE_UNITASK_SUPPORT
using Cysharp.Threading.Tasks;
#endif

namespace StellarArchive
{
    public abstract class BaseScene : MonoBehaviour
    {
#if STELLARARCHIVE_UNITASK_SUPPORT
        protected CancellationToken CancellationToken;

        private void Awake()
        {
            CancellationToken = gameObject.GetCancellationTokenOnDestroy();
        }

        protected virtual UniTaskVoid InitializeAsync(object data) { return default; }
        
        protected async UniTask LoadSceneAsync<T>(LoadSceneMode loadSceneMode = LoadSceneMode.Single) where T : BaseScene 
            => await LoadSceneAsync<T>(null, loadSceneMode);
        
        protected async UniTask LoadSceneAsync<T>(object data, LoadSceneMode loadSceneMode = LoadSceneMode.Single) where T : BaseScene
        {
            var nextSceneName = typeof(T).Name;

            await SceneManager.LoadSceneAsync(nextSceneName, loadSceneMode);
            
            var baseScene = FindObjectOfType<T>();
            baseScene.InitializeAsync(data);
#if UNITY_EDITOR
            Debug.Log($"[LoadSceneAsync] {nextSceneName}".FormatColoredString(Color.cyan));
#endif
        }
        
#endif
    }
}