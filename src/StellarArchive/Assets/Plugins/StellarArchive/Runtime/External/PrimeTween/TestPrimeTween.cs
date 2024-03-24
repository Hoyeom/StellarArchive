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
        foreach (var image in _images)
        {
            Tween.Rotation(image.transform, Vector3.up * 180, .5f);
            Tween.Color(image, Color.white, .5f);
            await UniTask.Delay(10);
        }
    }
    
    private async UniTaskVoid ClearAsync()
    {
        foreach (var image in _images)
        {
            Tween.Rotation(image.transform, Vector3.up * 90, .5f);
            Tween.Color(image, Color.white - Color.black, .5f);
            await UniTask.Delay(10);
        }
    }
#endif
}
