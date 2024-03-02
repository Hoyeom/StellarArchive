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
        private const string TemporarySceneName = "TemporaryScene";
        private object _data;
        
        private void Awake()
        {
            CancellationToken = gameObject.GetCancellationTokenOnDestroy();
        }

        private void Start()
        {
            InitializeAsync();
        }

        protected abstract UniTaskVoid InitializeAsync();

        protected async UniTask LoadSceneAsync<T>(LoadSceneMode loadSceneMode = LoadSceneMode.Single) where T : BaseScene 
            => await LoadSceneAsync<T>(null, loadSceneMode);

        protected async UniTask LoadSceneAsync<T>(object data, LoadSceneMode loadSceneMode = LoadSceneMode.Single) where T : BaseScene
        {
            var prevSceneName = GetType().Name;
            var nextSceneName = typeof(T).Name;

            if (loadSceneMode == LoadSceneMode.Single)
            {
                SceneManager.CreateScene(TemporarySceneName);
                await SceneManager.UnloadSceneAsync(prevSceneName);
                await SceneManager.LoadSceneAsync(nextSceneName, loadSceneMode);
            }
            else
            {
                await SceneManager.LoadSceneAsync(nextSceneName, loadSceneMode);
            }
            
            var baseScene = FindObjectOfType<T>();
            baseScene._data = data;
#if UNITY_EDITOR
            Debug.Log($"[LoadSceneAsync] {nextSceneName}".FormatColoredString(Color.cyan));
#endif
        }
    }
}