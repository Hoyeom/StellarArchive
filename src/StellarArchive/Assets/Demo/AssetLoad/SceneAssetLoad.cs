using System.Collections;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using StellarArchive;
using UnityEngine;

public class SceneAssetLoad : BaseScene
{
    protected override async UniTaskVoid InitializeAsync(object data)
    {
        await Loading.EndAnimationAsync(0);
        await LoadSceneAsync<SceneLauncher>();
    }
}
