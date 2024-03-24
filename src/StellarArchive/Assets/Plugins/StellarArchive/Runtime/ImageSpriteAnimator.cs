using System.Threading;
using UnityEngine;
using UnityEngine.UI;

#if STELLARARCHIVE_UNITASK_SUPPORT
using Cysharp.Threading.Tasks;
#endif

namespace StellarArchive
{
    [RequireComponent(typeof(Image))]
    [DisallowMultipleComponent]
    public class ImageSpriteAnimator : MonoBehaviour
    {
        [HideInInspector] [SerializeField] private Image _image;
        [SerializeField] private Sprite[] _sprites;
        [SerializeField] private float _delay = 0.08f;
        [SerializeField] private bool _repeat = true;
        [SerializeField] private bool _ignoreTimeScale = false;
        
        private CancellationTokenSource _cancellationTokenSource;

        private int _currentIndex;
        
        private void OnEnable()
        {
#if STELLARARCHIVE_UNITASK_SUPPORT
            UpdateChangeNextSpriteAsync().Forget();
#endif
        }

        private void OnDisable()
        {
            Dispose();
        }
        
        public float GetDelay() => _delay;
        
        private void Dispose()
        {
            _cancellationTokenSource?.Cancel();
            _cancellationTokenSource?.Dispose();
            _cancellationTokenSource = null;
        }
        
        public void SetSprites(Sprite[] sprites, float delay)
        {
            _sprites = sprites;
            _delay = delay;
#if STELLARARCHIVE_UNITASK_SUPPORT
            UpdateChangeNextSpriteAsync().Forget();
#endif
        }

#if STELLARARCHIVE_UNITASK_SUPPORT
        private async UniTaskVoid UpdateChangeNextSpriteAsync()
        {
            _currentIndex = 0;
            var milliSecondsDelay = Mathf.RoundToInt(_delay * 1000f);

            var lastIndex = _sprites.Length - 1;
            
            _image.enabled = true;
            if (milliSecondsDelay > 0)
            {
                Dispose();
                _cancellationTokenSource = new CancellationTokenSource();
                var cancellationToken = _cancellationTokenSource.Token;
                
                while (true)
                {
                    await UniTask.Delay(milliSecondsDelay, _ignoreTimeScale, PlayerLoopTiming.Update, cancellationToken);
                    if (!_repeat && _currentIndex == lastIndex)
                        break;
                    ChangeNextSprite();
                }
            }

            _image.enabled = false;
        }
#endif

        public void ChangeNextSprite()
        {
            _currentIndex = (_currentIndex + 1) % _sprites.Length;

            if (_sprites.Length > _currentIndex)
            {
                var nextSprite = _sprites[_currentIndex];
                _image.sprite = nextSprite;
            }
        }
        
#if UNITY_EDITOR
        private void OnValidate()
        {
            _image ??= GetComponent<Image>();
        }
#endif
    }
}
