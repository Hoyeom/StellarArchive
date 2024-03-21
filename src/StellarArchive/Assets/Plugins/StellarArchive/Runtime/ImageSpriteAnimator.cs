using System.Threading;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;

namespace StellarArchive
{
    [DisallowMultipleComponent]
    public class ImageSpriteAnimator : MonoBehaviour
    {
        [SerializeField] private Image _image;
        [SerializeField] private Sprite[] _sprites;
        [SerializeField] private float _delay = 0.08f;

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
            _currentIndex = 0;
            _delay = delay;
            
            UpdateChangeNextSpriteAsync().Forget();
        }

        
        private async UniTaskVoid UpdateChangeNextSpriteAsync()
        {
            var milliSecondsDelay = Mathf.RoundToInt(_delay * 1000f);

            if (milliSecondsDelay > 0)
            {
                Dispose();
                _cancellationTokenSource = new CancellationTokenSource();
                var cancellationToken = _cancellationTokenSource.Token;
                
                while (true)
                {
                    await UniTask.Delay(milliSecondsDelay, false, PlayerLoopTiming.Update, cancellationToken);
                    ChangeNextSprite();
                }   
            }
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
