// ReSharper disable CheckNamespace

using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace StellarArchive
{
    public abstract class BaseScene : MonoBehaviour
    {
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
    }
}