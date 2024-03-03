using System.Collections;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using StellarArchive;
using UnityEngine;

public class SceneLauncher : BaseScene
{
    // ReSharper disable once Unity.IncorrectMethodSignature
    protected async UniTaskVoid Start()
    {
        await LoadSceneAsync<SceneAssetLoad>();
    }
}
