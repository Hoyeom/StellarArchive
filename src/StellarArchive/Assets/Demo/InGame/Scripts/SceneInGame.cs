using System;
using Cysharp.Threading.Tasks;
using StellarArchive;
using UnityEngine;

public class SceneInGame : BaseScene
{
    private void Start()
    {
        InitializeAsync("{}").Forget();
    }

    protected override async UniTaskVoid InitializeAsync(object data)
    {
        var nav = new UINav();
        
        nav.RegisterAccessCondition<ScreenTestCanvas>(new AccessCondition(0, () =>
        {
            if (Input.GetKey(KeyCode.A))
            {
                return true;
            }
            // TODO Toast
            Debug.Log("A 키를 누른 후 열수 있습니다");
            return false;
        }));
        
        
        var canvas = await nav.GetAsync<TestCanvas>();
        canvas.TryOpenAsync().Forget();
    }
}
