using System;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.Serialization;

namespace StellarArchive
{
    public class LoadingCanvas : MonoBehaviour
    {
        [SerializeField] private Canvas _canvas;
        [SerializeField] private Animator _animator;
        private Dictionary<string, AnimationClip> _clipMap;
        private static readonly int End = Animator.StringToHash("End");
        private const string StartStateName = "Start";
        private const string ProgressStateName = "Progress";
        private const string EndStateName = "End";
        
        private void Awake()
        {
            _clipMap = new Dictionary<string, AnimationClip>();
            foreach (var clip in _animator.runtimeAnimatorController.animationClips)
                _clipMap.Add(clip.name, clip);
        }

#if STELLARARCHIVE_UNITASK_SUPPORT
        public async UniTask StartAsync()
        {
            _canvas.enabled = true;
            _animator.Play(StartStateName, -1, 0);
            var t = 0f;
            var duration = _clipMap[StartStateName].length;
            while (duration > t)
            {
                t += Time.deltaTime;
                await UniTask.Yield(PlayerLoopTiming.Update);
            }
            _animator.Play(ProgressStateName, -1, 0);
        }
        
        public async UniTask EndAsync()
        {
            _canvas.enabled = true;
            AnimatorStateInfo stateInfo = _animator.GetCurrentAnimatorStateInfo(0);
            float totalLength = stateInfo.length;

            float currentProgressTime = stateInfo.normalizedTime % 1.0f;

            float currentTime = totalLength * currentProgressTime;

            float remainingTime = totalLength - currentTime;
            
            
            _animator.SetTrigger(End);
            var t = 0f;
            var duration = _clipMap[EndStateName].length + remainingTime;
            while (duration > t)
            {
                t += Time.deltaTime;
                await UniTask.Yield(PlayerLoopTiming.Update);
            }
            
            _canvas.enabled = false;
        }
#endif
    }
}