using System.Collections;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using StellarArchive;
using UnityEngine;

public class SceneAssetLoad : BaseScene
{
    protected override async UniTaskVoid InitializeAsync()
    {
        await UniTask.Delay(2000, false, PlayerLoopTiming.Update, CancellationToken);
        await LoadSceneAsync<SceneLauncher>("SceneAssetLoad");
    }
}
