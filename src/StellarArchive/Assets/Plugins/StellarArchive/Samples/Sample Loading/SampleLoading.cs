using Cysharp.Threading.Tasks;
using UnityEngine;

namespace StellarArchive.Sample
{
    public class SampleLoading : MonoBehaviour
    {
        // ReSharper disable once Unity.IncorrectMethodSignature
        private async UniTaskVoid Start()
        {
            while (true)
            {
                await Loading.StartAnimationAsync(0);
                await Loading.EndAnimationAsync(0);
            }
        }
    }
}
