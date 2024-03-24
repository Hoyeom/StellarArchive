using System;
using Cysharp.Threading.Tasks;
using StellarArchive;

public class SceneInGame : BaseScene
{
    private void Start()
    {
        InitializeAsync("{}").Forget();
    }

    protected override async UniTaskVoid InitializeAsync(object data)
    {
        var nav = new UINav();

        var canvas = await nav.GetAsync<AuthCanvas>();
        
        canvas.TryOpen();
        // canvas.SetVisible(true);
    }
}
