using System.Threading;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;

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
        
        private CancellationTokenSource _cancellationTokenSource;

        private int _currentIndex;
        
        private void OnEnable()
        {
            UpdateChangeNextSpriteAsync().Forget();
        }

        private void OnDisable()
        {
            Dispose();
        }

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
            
            UpdateChangeNextSpriteAsync().Forget();
        }

        
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
                    await UniTask.Delay(milliSecondsDelay, false, PlayerLoopTiming.Update, cancellationToken);
                    if (!_repeat && _currentIndex == lastIndex)
                        break;
                    ChangeNextSprite();
                }
            }

            _image.enabled = false;
        }
        
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

        public float GetDelay() => _delay;
#endif
    }
}
