// ReSharper disable CheckNamespace

using System.Threading;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;
#if STELLARARCHIVE_UNITASK_SUPPORT
using Cysharp.Threading.Tasks;
#endif

namespace StellarArchive
{
    [AddComponentMenu("StellarArchive/UI/SaButton", 0)]
    public class SaButton : Selectable, IPointerClickHandler, ISubmitHandler
    {
        [SerializeField] private UnityEvent onClick;
        [SerializeField] private float scaleFactor = 0.95f;
        [SerializeField] private float scaleFactorDuration = 0.1f;
        private Vector3 _initialScale;
        private bool _isPointerDown;
        private bool _isPointerInside;
#if STELLARARCHIVE_UNITASK_SUPPORT
        private CancellationToken _cancellationToken;
#endif
        protected override void Start()
        {
            _initialScale = transform.localScale;
#if STELLARARCHIVE_UNITASK_SUPPORT
            _cancellationToken = gameObject.GetCancellationTokenOnDestroy();
#endif
        }

        public void OnPointerClick(PointerEventData eventData)
        {
            if (eventData.button != PointerEventData.InputButton.Left)
                return;
            
            Press();
        }

        public void OnSubmit(BaseEventData eventData)
        {
            Press();

            if (!IsActive() || !IsInteractable())
                return;

            DoStateTransition(SelectionState.Pressed, false);
            
#if STELLARARCHIVE_UNITASK_SUPPORT
            OnSizeUpAsync().Forget();
            OnFinishSubmitAsync().Forget();
#endif
        }

        public override void OnPointerDown(PointerEventData eventData)
        {
            base.OnPointerDown(eventData);
            
            if (eventData.button != PointerEventData.InputButton.Left)
                return;
            
            if (_isPointerInside)
            {
                _isPointerDown = true; 
#if STELLARARCHIVE_UNITASK_SUPPORT
                OnSizeDownAsync().Forget();
#endif
            }
        }

        public override void OnPointerUp(PointerEventData eventData)
        {
            base.OnPointerUp(eventData);

            if (eventData.button != PointerEventData.InputButton.Left)
                return;
            
            if (!IsActive() || !IsInteractable())
                return;

            _isPointerDown = false;

            if (_isPointerInside)
            { 
#if STELLARARCHIVE_UNITASK_SUPPORT
                OnSizeUpAsync().Forget();
#endif
            }
    
            DoStateTransition(SelectionState.Pressed, false);
#if STELLARARCHIVE_UNITASK_SUPPORT
            OnFinishSubmitAsync().Forget();
#endif
        }

        public override void OnPointerExit(PointerEventData eventData)
        {
            base.OnPointerExit(eventData);
            _isPointerInside = false;
            
            if (_isPointerDown)
            { 
#if STELLARARCHIVE_UNITASK_SUPPORT
                OnSizeUpAsync().Forget();
#endif
            }
        }

        public override void OnPointerEnter(PointerEventData eventData)
        {
            base.OnPointerEnter(eventData);
            _isPointerInside = true;

            if (eventData.delta.sqrMagnitude > 0)
            {
                if (_isPointerDown)
                {
#if STELLARARCHIVE_UNITASK_SUPPORT
                    OnSizeDownAsync().Forget();
#endif
                }
            }            
        }

        private void Press()
        {
            if (!IsActive() || !IsInteractable())
                return;

            onClick.Invoke();
        }
        
#if STELLARARCHIVE_UNITASK_SUPPORT
        private async UniTaskVoid OnSizeDownAsync()
        {
            var fadeTime = scaleFactorDuration;
            var elapsedTime = 0f;
            var targetScale = _initialScale * scaleFactor;
    
            while (elapsedTime < fadeTime)
            {
                transform.localScale = Vector3.Lerp(_initialScale, targetScale, elapsedTime / fadeTime);
                elapsedTime += Time.unscaledDeltaTime;
                await UniTask.Yield(_cancellationToken);
            }
            
            transform.localScale = targetScale;
        }

        private async UniTaskVoid OnSizeUpAsync()
        {
            var fadeTime = scaleFactorDuration;
            var elapsedTime = 0f;
            var targetScale = _initialScale * scaleFactor;
    
            while (elapsedTime < fadeTime)
            {
                transform.localScale = Vector3.Lerp(targetScale, _initialScale, elapsedTime / fadeTime);
                elapsedTime += Time.unscaledDeltaTime;
                await UniTask.Yield(_cancellationToken);
            }

            transform.localScale = _initialScale;
        }
        
        private async UniTaskVoid OnFinishSubmitAsync()
        {
            var fadeTime = colors.fadeDuration;
            var elapsedTime = 0f;

            while (elapsedTime < fadeTime)
            {
                elapsedTime += Time.unscaledDeltaTime;
                await UniTask.Yield(_cancellationToken);
            }

            DoStateTransition(currentSelectionState, false);
        }
#endif


        public void RemoveAllListeners()
        {
            onClick.RemoveAllListeners();
        }
        
        public void RemoveListener(UnityAction action)
        {
            onClick.RemoveListener(action);
        }
        
        public void AddListener(UnityAction action)
        {
            onClick.AddListener(action);
        }
        
        
    }
}