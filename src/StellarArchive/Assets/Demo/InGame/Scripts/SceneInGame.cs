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

        var canvas = await nav.GetAsync<TestCanvas>();
        canvas.TryOpenAsync().Forget();

        nav.RegisterAccessCondition<PopupTestCanvas>(new AccessCondition(0,
            () =>
            {
                // Ex 특정 레벨 달성
                if(!Input.GetKey(KeyCode.N))
                    Debug.Log("N 눌러야함");
                return Input.GetKey(KeyCode.N);
            }));

        // canvas.SetVisible(true);
    }
}
