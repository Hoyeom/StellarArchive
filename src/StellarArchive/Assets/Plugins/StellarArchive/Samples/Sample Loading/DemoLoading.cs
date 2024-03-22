using Cysharp.Threading.Tasks;
using UnityEngine;

namespace StellarArchive.Sample
{
    public class DemoLoading : MonoBehaviour
    {
        // ReSharper disable once Unity.IncorrectMethodSignature
        private async UniTaskVoid Start()
        {
            Time.timeScale = 0;
            while (true)
            {
                await Loading.StartAnimationAsync(0);
                await Loading.EndAnimationAsync(0);
            }
        }
    }
}
