using System;
using System.Collections;
using System.Collections.Generic;
using PrimeTween;
using UnityEngine;
using UnityEngine.UI;

#if STELLARARCHIVE_UNITASK_SUPPORT
using Cysharp.Threading.Tasks;
#endif

public class TestPrimeTween : MonoBehaviour
{
    [SerializeField] private Image[] _images;
 
#if STELLARARCHIVE_PRIMETWEEN_SUPPORT && STELLARARCHIVE_UNITASK_SUPPORT

    // ReSharper disable once Unity.IncorrectMethodSignature
    private async UniTaskVoid Start()
    {
        ClearAsync().Forget();
        bool isSpace = false;
     
        while (true)
        {
            if (isSpace)
            {
                if (Input.GetKeyDown(KeyCode.Space))
                {
                    ClearAsync().Forget();
                    isSpace = false;
                }
            }
            else
            {
                if (Input.GetKeyDown(KeyCode.Space))
                {
                    RotationAsync().Forget();
                    isSpace = true;
                }
            }
            

            
            await UniTask.Yield(PlayerLoopTiming.Update);
        }
    }

    private async UniTaskVoid RotationAsync()
    {
        float duration = .1f;
        
        foreach (var image in _images)
        {
            Tween.Rotation(image.transform, Vector3.zero, duration);
            Tween.Color(image, Color.white, duration);
            await UniTask.Delay(1);
        }
    }
    
    private async UniTaskVoid ClearAsync()
    {
        float duration = .1f;

        foreach (var image in _images)
        {
            Tween.Rotation(image.transform, Vector3.up * 90 + Vector3.forward * 45, duration);
            Tween.Color(image, Color.white - Color.black, duration);
            await UniTask.Delay(1);
        }
    }
#endif
}
