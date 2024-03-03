using System;
using System.Collections.Generic;
using System.Threading;
using Object = UnityEngine.Object;

#if STELLARARCHIVE_ADDRESSABLE_SUPPORT
using UnityEngine.AddressableAssets;
#endif

#if STELLARARCHIVE_UNITASK_SUPPORT
using Cysharp.Threading.Tasks;
#endif

namespace StellarArchive
{
    public class Loading
    {
        public enum Status
        {
            None,
            Started,
            InProgress,
            Completed,
        }
        
        public class Data
        {
            public LoadingCanvas LoadingCanvas;
            public Status Status;
        
            public Data(LoadingCanvas loadingCanvas)
            {
                LoadingCanvas = loadingCanvas;
                Status = Status.None;
            }
        }
        

        
        private static LoadingSetting _loadingSetting;
        private static Dictionary<int, Data> _loadingDataMap;
#if STELLARARCHIVE_UNITASK_SUPPORT
        
        public static async UniTask StartAnimationAsync(Enum key)
        {
            await StartAnimationAsync(Convert.ToInt32(key));
        }
        
        public static async UniTask StartAnimationAsync(int key)
        {
            if (_loadingSetting == null)
            {
#if STELLARARCHIVE_ADDRESSABLE_SUPPORT
                var handle = Addressables.LoadAssetAsync<LoadingSetting>(nameof(LoadingSetting));
                await handle;
                _loadingSetting = handle.Result;
#endif
                _loadingDataMap = new Dictionary<int, Data>();
            }

            if (!_loadingDataMap.ContainsKey(key))
            {
                var prefab = _loadingSetting.loadingCanvasPrefab[key];
                var loadingCanvas = Object.Instantiate(prefab);
                Object.DontDestroyOnLoad(loadingCanvas.gameObject);
                _loadingDataMap.Add(key, new Data(loadingCanvas));
            }

            _loadingDataMap[key].Status = Status.Started;
            await _loadingDataMap[key].LoadingCanvas.StartAsync();
            _loadingDataMap[key].Status = Status.InProgress;
        }
        
        public static async UniTask EndAnimationAsync(int key)
        {
            if (!_loadingDataMap.ContainsKey(key))
                return;
            if (_loadingDataMap[key].Status == Status.InProgress)
            {
                await _loadingDataMap[key].LoadingCanvas.EndAsync();
                _loadingDataMap[key].Status = Status.Completed;
            }
        }
#endif

    }
}