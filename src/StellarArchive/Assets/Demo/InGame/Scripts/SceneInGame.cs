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
        
        nav.RegisterSetup<ScreenTestCanvas>(canvas =>
        {
            
        });
        
        nav.RegisterAccessCondition<ScreenTestCanvas>(new AccessCondition(0, () => Input.GetKey(KeyCode.A)));
        
        var canvas = await nav.GetAsync<TestCanvas>();
        canvas.TryOpenAsync().Forget();
        
        // PointerEventData pointerEventData = new PointerEventData(EventSystem.current);
        // ExecuteEvents.Execute(buttonGameObject, pointerEventData, ExecuteEvents.pointerClickHandler);
    }
}
