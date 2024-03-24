using UnityEngine;

#if STELLARARCHIVE_UNITASK_SUPPORT
using Cysharp.Threading.Tasks;
#endif

namespace StellarArchive.Sample
{
    public class SampleLoading : MonoBehaviour
    {
#if STELLARARCHIVE_UNITASK_SUPPORT
        
        // ReSharper disable once Unity.IncorrectMethodSignature
        private async UniTaskVoid Start()
        {
            while (true)
            {
                await Loading.StartAnimationAsync(0);
                await Loading.EndAnimationAsync(0);
            }
        }
#endif

    }
}
