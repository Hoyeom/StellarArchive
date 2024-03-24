using System;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using UnityEngine.Serialization;

#if STELLARARCHIVE_UNITASK_SUPPORT
using Cysharp.Threading.Tasks;
#endif

namespace StellarArchive
{
    public class LoadingCanvas : MonoBehaviour
    {
        [SerializeField] private Canvas _canvas;
        [SerializeField] private Animator _animator;
        private Dictionary<string, AnimationClip> _clipMap;
        private CancellationToken _cancellationToken;
        
        private static readonly int End = Animator.StringToHash("End");
        
        private const string StartStateName = "Start";
        private const string ProgressStateName = "Progress";
        private const string EndStateName = "End";
        
        private void Awake()
        {
#if STELLARARCHIVE_UNITASK_SUPPORT
            _cancellationToken = gameObject.GetCancellationTokenOnDestroy();
#endif
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
                t += Time.unscaledDeltaTime;
                await UniTask.Yield(PlayerLoopTiming.Update, _cancellationToken);
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

            _animator.SetTrigger(End);
            var t = 0f;
            var duration = _clipMap[EndStateName].length + currentTime;
            while (duration > t)
            {
                t += Time.unscaledDeltaTime;
                await UniTask.Yield(PlayerLoopTiming.Update, _cancellationToken);
            }
            
            _canvas.enabled = false;
        }
#endif
    }
}