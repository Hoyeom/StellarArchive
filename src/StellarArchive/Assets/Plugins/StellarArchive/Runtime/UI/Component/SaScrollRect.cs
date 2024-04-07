using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Pool;
using UnityEngine.Serialization;
using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace StellarArchive
{
    [AddComponentMenu("StellarArchive/Scroll Rect")]
    [SelectionBase]
    [ExecuteAlways]
    [DisallowMultipleComponent]
    [RequireComponent(typeof(RectTransform))]
    public class SaScrollRect : UIBehaviour,
        IInitializePotentialDragHandler, 
        IBeginDragHandler, 
        IEndDragHandler,
        IDragHandler,
        IScrollHandler, 
        ICanvasElement, 
        ILayoutElement, 
        ILayoutGroup
    {
        public enum MovementType
        {
            Unrestricted,
            Elastic,
            Clamped,
        }
        
        public enum ScrollbarVisibility
        {
            Permanent,
            AutoHide,
            AutoHideAndExpandViewport,
        }

        public enum Direction
        {
            Horizontal,
            Vertical,
        }
        
        [Serializable]
        public class ScrollRectEvent : UnityEvent<Vector2> {}
        
        [SerializeField] private Vector2 _velocity;
        [SerializeField] private MovementType _movementType = MovementType.Elastic;
        [SerializeField] private ScrollbarVisibility _scrollbarVisibility;
        [SerializeField] private Direction _direction;
        [SerializeField] private RectTransform _viewport;
        [SerializeField] private RectTransform _content;
        [SerializeField] private Scrollbar _horizontalScrollbar;
        [SerializeField] private Scrollbar _verticalScrollbar;
        [SerializeField] private float _horizontalScrollbarSpacing;
        [SerializeField] private float _verticalScrollbarSpacing;
        [NonSerialized] private RectTransform _rect;
        [NonSerialized] private bool _hasRebuiltLayout = false;
        [SerializeField] private float _elasticity = 0.1f;
        [SerializeField] private float _scrollSensitivity = 1.0f; 
        [SerializeField] private bool _inertia = true;
        [SerializeField] private float _decelerationRate = 0.135f;
        [SerializeField] private ScrollRectEvent _onValueChanged = new ScrollRectEvent();
        [SerializeField] private ScrollbarVisibility _horizontalScrollbarVisibility;
        [SerializeField] private ScrollbarVisibility _verticalScrollbarVisibility;
        [SerializeField] private GameObject _testPrefab;
        [SerializeField] private Vector2 _itemSize;
        
        private Vector2 _contentStartPosition = Vector2.zero;
        private Vector2 _contentVirtualPosition = Vector2.zero;
        private Bounds _contentBounds;
        private Bounds _loopContentBounds;
        
        private Vector2 _pointerStartLocalCursor = Vector2.zero;
        private bool _dragging;
        private bool _scrolling;
        private RectTransform _viewRect;
        private Bounds _viewBounds;
        private DrivenRectTransformTracker _tracker;
        private RectTransform _horizontalScrollbarRect;
        private RectTransform _verticalScrollbarRect;
        private VerticalLayoutGroup _verticalLayoutGroup;
        private HorizontalLayoutGroup _horizontalLayoutGroup;
        private bool _hSliderExpand;
        private bool _vSliderExpand;
        private float _hSliderHeight;
        private float _vSliderWidth;
        private int _maxObjectCount;
        private Vector2 _prevPosition = Vector2.zero;
        private Bounds _prevContentBounds;
        private Bounds _prevViewBounds;
        private int _itemCount;
        private int _itemIndex;
        private List<GameObject> _gameObjects = new List<GameObject>();

        public delegate void OnUpdateItemHandler(int objectIndex, int itemIndex);
        public event OnUpdateItemHandler OnUpdateItem = delegate { }; 
        public virtual float minWidth => -1;
        public virtual float preferredWidth => -1;
        public virtual float flexibleWidth => -1;
        public virtual float minHeight => -1;
        public virtual float preferredHeight => -1;
        public virtual float flexibleHeight => -1;

        public virtual int layoutPriority { get { return -1; } }
        public float horizontalScrollbarSpacing { get { return _horizontalScrollbarSpacing; } set { _horizontalScrollbarSpacing = value; SetDirty(); } }
        public float verticalScrollbarSpacing { get { return _verticalScrollbarSpacing; } set { _verticalScrollbarSpacing = value; SetDirty(); } }
        
        public Vector2 velocity { get { return _velocity; } set { _velocity = value; } }
        public MovementType movementType { get { return _movementType; } set { _movementType = value; } }
        public Direction direction { get { return _direction; } set { _direction = value; } }
        public ScrollbarVisibility scrollbarVisibility { get { return _scrollbarVisibility; } set { _scrollbarVisibility = value; SetDirtyCaching(); } }
        public RectTransform viewport { get { return _viewport; } set { _viewport = value; SetDirtyCaching(); } }
        public RectTransform content { get { return _content; } set { _content = value; } }
        public bool inertia { get { return _inertia; } set { _inertia = value; } }
        public float decelerationRate { get { return _decelerationRate; } set { _decelerationRate = value; } }
        public ScrollbarVisibility horizontalScrollbarVisibility { get { return _horizontalScrollbarVisibility; } set { _horizontalScrollbarVisibility = value; SetDirtyCaching(); } }
        public ScrollbarVisibility verticalScrollbarVisibility { get { return _verticalScrollbarVisibility; } set { _verticalScrollbarVisibility = value; SetDirtyCaching(); } }

        
        public Vector2 normalizedPosition
        {
            get
            {
                return new Vector2(horizontalNormalizedPosition, verticalNormalizedPosition);
            }
            set
            {
                SetNormalizedPosition(value.x, 0);
                SetNormalizedPosition(value.y, 1);
            }
        }
        
        public float horizontalNormalizedPosition
        {
            get
            {
                UpdateBounds();
                
                if ((_contentBounds.size.x <= _viewBounds.size.x) || Mathf.Approximately(_contentBounds.size.x, _viewBounds.size.x))
                    return (_viewBounds.min.x > _contentBounds.min.x) ? 1 : 0;
                return (_viewBounds.min.x - _contentBounds.min.x) / (_contentBounds.size.x - _viewBounds.size.x);
            }
            set
            {
                SetNormalizedPosition(value, 0);
            }
        }
        
        public float verticalNormalizedPosition
        {
            get
            {
                UpdateBounds();
                if ((_loopContentBounds.size.y <= _viewBounds.size.y) || Mathf.Approximately(_loopContentBounds.size.y, _viewBounds.size.y))
                    return (_viewBounds.min.y > _loopContentBounds.min.y) ? 1 : 0;
                
                return 1 - (_contentVirtualPosition.y) / (_loopContentBounds.size.y - _viewBounds.size.y);
                // return (_viewBounds.min.y - _loopContentBounds.min.y) / (_loopContentBounds.size.y - _viewBounds.size.y);
            }
            set
            {
                SetNormalizedPosition(value, 1);
            }
        }
        
        public Scrollbar horizontalScrollbar
        {
            get
            {
                return _horizontalScrollbar;
            }
            set
            {
                if (_horizontalScrollbar)
                    _horizontalScrollbar.onValueChanged.RemoveListener(SetHorizontalNormalizedPosition);
                _horizontalScrollbar = value;
                if (direction is Direction.Horizontal && _horizontalScrollbar)
                    _horizontalScrollbar.onValueChanged.AddListener(SetHorizontalNormalizedPosition);
                SetDirtyCaching();
            }
        }
        
        public Scrollbar verticalScrollbar
        {
            get
            {
                return _verticalScrollbar;
            }
            set
            {
                if (_verticalScrollbar)
                    _verticalScrollbar.onValueChanged.RemoveListener(SetVerticalNormalizedPosition);
                _verticalScrollbar = value;
                if (direction is Direction.Vertical && _verticalScrollbar)
                    _verticalScrollbar.onValueChanged.AddListener(SetVerticalNormalizedPosition);
                SetDirtyCaching();
            }
        }

        
        protected RectTransform viewRect
        {
            get
            {
                if (_viewRect == null)
                    _viewRect = _viewport;
                if (_viewRect == null)
                    _viewRect = (RectTransform)transform;
                return _viewRect;
            }
        }

        private RectTransform rectTransform
        {
            get
            {
                if (_rect == null)
                    _rect = GetComponent<RectTransform>();
                return _rect;
            }
        }
        
        private bool hScrollingNeeded
        {
            get
            {
                if (Application.isPlaying)
                    return _contentBounds.size.x > _viewBounds.size.x + 0.01f;
                return true;
            }
        }
        private bool vScrollingNeeded
        {
            get
            {
                if (Application.isPlaying)
                    return _contentBounds.size.y > _viewBounds.size.y + 0.01f;
                return true;
            }
        }

        protected override void Awake()
        {
            if (_content != null)
            {
                if (_direction is Direction.Horizontal)
                {
                    _horizontalLayoutGroup = content.GetComponent<HorizontalLayoutGroup>();
                }
                else
                {
                    _verticalLayoutGroup = content.GetComponent<VerticalLayoutGroup>();
                }
                
                _itemIndex = 0;
            }
        }

        protected override void OnEnable()
        {
            if (_direction is Direction.Horizontal && _horizontalScrollbar)
                _horizontalScrollbar.onValueChanged.AddListener(SetHorizontalNormalizedPosition);
            if (_direction is Direction.Vertical && _verticalScrollbar)
                _verticalScrollbar.onValueChanged.AddListener(SetVerticalNormalizedPosition);

            _itemCount = 100;
            
            CanvasUpdateRegistry.RegisterCanvasElementForLayoutRebuild(this);
            SetDirty();
        }

        private void LateUpdate()
        {
            if (!_content)
                return;
            
            EnsureLayoutHasRebuilt();
            UpdateBounds();
            float deltaTime = Time.unscaledDeltaTime;
            Vector2 offset = CalculateOffset(Vector2.zero);
            
            if (deltaTime > 0.0f)
            {
                if (!_dragging && (offset != Vector2.zero || _velocity != Vector2.zero))
                {
                    Vector2 position = _content.anchoredPosition;
                    for (int axis = 0; axis < 2; axis++)
                    {
                        if (_movementType == MovementType.Elastic && offset[axis] != 0)
                        {
                            float speed = _velocity[axis];
                            float smoothTime = _elasticity;
                            if (_scrolling)
                                smoothTime *= 3.0f;
                            position[axis] = Mathf.SmoothDamp(_content.anchoredPosition[axis], _content.anchoredPosition[axis] + offset[axis], ref speed, smoothTime, Mathf.Infinity, deltaTime);
                            if (Mathf.Abs(speed) < 1)
                                speed = 0;
                            _velocity[axis] = speed;
                        }
                        // Else move content according to velocity with deceleration applied.
                        else if (_inertia)
                        {
                            _velocity[axis] *= Mathf.Pow(_decelerationRate, deltaTime);
                            if (Mathf.Abs(_velocity[axis]) < 1)
                                _velocity[axis] = 0;
                            position[axis] += _velocity[axis] * deltaTime;
                        }
                        // If we have neither elaticity or friction, there shouldn't be any velocity.
                        else
                        {
                            _velocity[axis] = 0;
                        }
                    }

                    if (_movementType == MovementType.Clamped)
                    {
                        offset = CalculateOffset(position - _content.anchoredPosition);
                        position += offset;
                    }
                    
                    SetContentAnchoredPosition(position);
                }

                if (_dragging && _inertia)
                {
                    Vector3 newVelocity = (_content.anchoredPosition - _prevPosition) / deltaTime;
                    _velocity = Vector3.Lerp(_velocity, newVelocity, deltaTime * 10);
                }
            }

            if (_viewBounds != _prevViewBounds || _contentBounds != _prevContentBounds || _content.anchoredPosition != _prevPosition)
            {
                UpdateScrollbars(offset);
                UISystemProfilerApi.AddMarker("ScrollRect.value", this);
                _onValueChanged.Invoke(normalizedPosition);
                UpdatePrevData();
            }
            
            UpdateScrollbarVisibility();
            _scrolling = false;
        }

        private void UpdateScrollbarVisibility()
        {
            UpdateOneScrollbarVisibility(vScrollingNeeded, direction is Direction.Vertical, _verticalScrollbarVisibility, _verticalScrollbar);
            UpdateOneScrollbarVisibility(hScrollingNeeded, direction is Direction.Horizontal, _horizontalScrollbarVisibility, _horizontalScrollbar);
        }
        
        private void UpdatePrevData()
        {
            if (_content == null)
            {
                _prevPosition = Vector2.zero;
            }
            else
            {
                _prevPosition = _content.anchoredPosition;
            }
            _prevViewBounds = _viewBounds;
            _prevContentBounds = _contentBounds;
        }
        
        private void UpdateScrollbars(Vector2 offset)
        {
            if (_horizontalScrollbar)
            {
                if (_contentBounds.size.x > 0)
                    _horizontalScrollbar.size = Mathf.Clamp01((_viewBounds.size.x - Mathf.Abs(offset.x)) / _contentBounds.size.x);
                else
                    _horizontalScrollbar.size = 1;

                _horizontalScrollbar.SetValueWithoutNotify(horizontalNormalizedPosition);
            }

            if (_verticalScrollbar)
            {
                if (_contentBounds.size.y > 0)
                    _verticalScrollbar.size = Mathf.Clamp01((_viewBounds.size.y - Mathf.Abs(offset.y)) / _loopContentBounds.size.y);
                else
                    _verticalScrollbar.size = 1;

                // var normalize = 1 - (float)_itemIndex / (_itemCount - _maxObjectCount);
                // _verticalScrollbar.SetValueWithoutNotify(normalize);
                _verticalScrollbar.SetValueWithoutNotify(verticalNormalizedPosition);
            }
        }
        
        private void SetDirty()
        {
            LayoutRebuilder.MarkLayoutForRebuild(rectTransform);
        }
        
        private void EnsureLayoutHasRebuilt()
        {
            if (!_hasRebuiltLayout && !CanvasUpdateRegistry.IsRebuildingLayout())
                Canvas.ForceUpdateCanvases();
        }

        protected virtual void SetNormalizedPosition(float value, int axis)
        {
            EnsureLayoutHasRebuilt();
            UpdateBounds();
            float hiddenLength = _loopContentBounds.size[axis] - _viewBounds.size[axis];
            
            _itemIndex = Mathf.RoundToInt(Mathf.Lerp(0, _itemCount - _maxObjectCount, 1 - value));
            _contentVirtualPosition[axis] = hiddenLength * (1 - value);
            var anchoredPosition = _content.anchoredPosition;
            
            var newAnchoredPosition = _contentVirtualPosition[axis];
            
            Debug.Log($"[SetNormalizedPosition] {newAnchoredPosition} {value}");
            
            float top = _verticalLayoutGroup.padding.top;
            float bottom = _verticalLayoutGroup.padding.bottom;
            float spacing = _verticalLayoutGroup.spacing;
            float itemSize = _itemSize.y;
            float topBound = (itemSize + spacing) * 3 - spacing + top;
            var offset = (itemSize + spacing) * 2 - spacing;
            float scrollEndPos = _content.rect.size.y - _rect.rect.size.y;
            float bottomBound = scrollEndPos - ((itemSize + spacing) * 3 - spacing + bottom);

            if (newAnchoredPosition > topBound)
            {
                if (topBound > (hiddenLength - newAnchoredPosition))
                {
                    newAnchoredPosition = topBound + (_maxObjectCount - 1) * spacing + (newAnchoredPosition % itemSize);
                }
                else
                {
                    newAnchoredPosition = offset + (newAnchoredPosition % itemSize);
                }
            }
            
            newAnchoredPosition = Mathf.Clamp(newAnchoredPosition, 0, scrollEndPos);

            
            if (Mathf.Abs(anchoredPosition[axis] - newAnchoredPosition) > 0.01f)
            {
                anchoredPosition[axis] = newAnchoredPosition;
                _content.anchoredPosition = anchoredPosition;
                _velocity[axis] = 0;
                
                UpdateItems();
                UpdateBounds();
            }
        }

        
        private void SetHorizontalNormalizedPosition(float value) { SetNormalizedPosition(value, 0); }
        private void SetVerticalNormalizedPosition(float value) { SetNormalizedPosition(value, 1); }

        public void OnInitializePotentialDrag(PointerEventData eventData)
        {
            if (eventData.button != PointerEventData.InputButton.Left)
                return;

            _velocity = Vector2.zero;
        }

        public void OnBeginDrag(PointerEventData eventData)
        {
            if (eventData.button != PointerEventData.InputButton.Left)
                return;

            UpdateBounds();
            
            _pointerStartLocalCursor = Vector2.zero;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(viewRect, eventData.position, eventData.pressEventCamera, out _pointerStartLocalCursor);
            _contentStartPosition = _content.anchoredPosition;
            _dragging = true;
        }

        public void OnEndDrag(PointerEventData eventData)
        {
            if (eventData.button != PointerEventData.InputButton.Left)
                return;

            _dragging = false;
        }

        public void OnDrag(PointerEventData eventData)
        {
            if (!_dragging)
                return;

            if (eventData.button != PointerEventData.InputButton.Left)
                return;

            if (!IsActive())
                return;

            Vector2 localCursor;
            if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(viewRect, eventData.position, eventData.pressEventCamera, out localCursor))
                return;

            UpdateBounds();

            var pointerDelta = localCursor - _pointerStartLocalCursor;
            Vector2 position = _contentStartPosition + pointerDelta;
            // Offset to get content into place in the view.
            Vector2 offset = CalculateOffset(position - _content.anchoredPosition);
            
            position += offset;
            if (_movementType == MovementType.Elastic)
            {
                if (offset.x != 0)
                    position.x = position.x - RubberDelta(offset.x, _viewBounds.size.x);
                if (offset.y != 0)
                    position.y = position.y - RubberDelta(offset.y, _viewBounds.size.y);
            }

            SetContentAnchoredPosition(position);
        }

        public void OnScroll(PointerEventData data)
        {
            EnsureLayoutHasRebuilt();
            UpdateBounds();

            Vector2 delta = data.scrollDelta;
            delta.y *= -1;
            if (_direction is Direction.Vertical)
            {
                if (Mathf.Abs(delta.x) > Mathf.Abs(delta.y))
                    delta.y = delta.x;
                delta.x = 0;
            }
            if (_direction is Direction.Horizontal)
            {
                if (Mathf.Abs(delta.y) > Mathf.Abs(delta.x))
                    delta.x = delta.y;
                delta.y = 0;
            }

            if (data.IsScrolling())
                _scrolling = true;

            Vector2 position = _content.anchoredPosition;
            position += delta * _scrollSensitivity;
            if (_movementType == MovementType.Clamped)
                position += CalculateOffset(position - _content.anchoredPosition);

            SetContentAnchoredPosition(position);
            UpdateBounds();
        }
        
        void UpdateCachedData()
        {
            Transform transform = this.transform;
            _horizontalScrollbarRect = _horizontalScrollbar == null ? null : _horizontalScrollbar.transform as RectTransform;
            _verticalScrollbarRect = _verticalScrollbar == null ? null : _verticalScrollbar.transform as RectTransform;

            bool viewIsChild = (viewRect.parent == transform);
            bool hScrollbarIsChild = (!_horizontalScrollbarRect || _horizontalScrollbarRect.parent == transform);
            bool vScrollbarIsChild = (!_verticalScrollbarRect || _verticalScrollbarRect.parent == transform);
            bool allAreChildren = (viewIsChild && hScrollbarIsChild && vScrollbarIsChild);

            _hSliderExpand = allAreChildren && _horizontalScrollbarRect && horizontalScrollbarVisibility == ScrollbarVisibility.AutoHideAndExpandViewport;
            _vSliderExpand = allAreChildren && _verticalScrollbarRect && verticalScrollbarVisibility == ScrollbarVisibility.AutoHideAndExpandViewport;
            _hSliderHeight = (_horizontalScrollbarRect == null ? 0 : _horizontalScrollbarRect.rect.height);
            _vSliderWidth = (_verticalScrollbarRect == null ? 0 : _verticalScrollbarRect.rect.width);

            _maxObjectCount = CalculateViewportMaxItemCount() + 4;

#if UNITY_EDITOR
            if(!Application.isPlaying) return;
#endif
            if(_testPrefab == null) return;
            
            for (int i = _gameObjects.Count; i < _maxObjectCount; i++)
            {
                _gameObjects.Add(Instantiate(_testPrefab, _content));
                _gameObjects[i].name = (i + 1).ToString();
            }
        }

        int CalculateViewportMaxItemCount()
        {
            if (_direction is Direction.Vertical)
            {
                float spacing = _verticalLayoutGroup.spacing;
                float itemHeight = _itemSize.y;
                float viewRectHeight = _rect.rect.height;
                int maxItemCount = Mathf.CeilToInt(viewRectHeight / (itemHeight + spacing));
                return maxItemCount;
            }
            
            return 0;
        }

        public void Rebuild(CanvasUpdate executing)
        {
            if (executing == CanvasUpdate.Prelayout)
            {
                UpdateCachedData();
            }

            if (executing == CanvasUpdate.PostLayout)
            {
                UpdateBounds();
                UpdateScrollbars(Vector2.zero);
                UpdatePrevData();

                _hasRebuiltLayout = true;
            }
        }

        public void LayoutComplete()
        {
            
        }

        public void GraphicUpdateComplete()
        {
            
        }

        public void CalculateLayoutInputHorizontal()
        {
            
        }

        public void CalculateLayoutInputVertical()
        {
            
        }

       
        public void SetLayoutHorizontal()
        {
            _tracker.Clear();
            UpdateCachedData();

            if (_hSliderExpand || _vSliderExpand)
            {
                _tracker.Add(this, viewRect,
                    DrivenTransformProperties.Anchors |
                    DrivenTransformProperties.SizeDelta |
                    DrivenTransformProperties.AnchoredPosition);

                viewRect.anchorMin = Vector2.zero;
                viewRect.anchorMax = Vector2.one;
                viewRect.sizeDelta = Vector2.zero;
                viewRect.anchoredPosition = Vector2.zero;

                LayoutRebuilder.ForceRebuildLayoutImmediate(content);
                _viewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
                _contentBounds = GetBounds();
                _loopContentBounds = GetLoopBounds();
            }

            if (_vSliderExpand && vScrollingNeeded)
            {
                viewRect.sizeDelta = new Vector2(-(_vSliderWidth + _verticalScrollbarSpacing), viewRect.sizeDelta.y);

                LayoutRebuilder.ForceRebuildLayoutImmediate(content);
                _viewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
                _contentBounds = GetBounds();
                _loopContentBounds = GetLoopBounds();
            }

            if (_hSliderExpand && hScrollingNeeded)
            {
                viewRect.sizeDelta = new Vector2(viewRect.sizeDelta.x, -(_hSliderHeight + _horizontalScrollbarSpacing));
                _viewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
                _contentBounds = GetBounds();
                _loopContentBounds = GetLoopBounds();
            }

            if (_vSliderExpand && vScrollingNeeded && viewRect.sizeDelta.x == 0 && viewRect.sizeDelta.y < 0)
            {
                viewRect.sizeDelta = new Vector2(-(_vSliderWidth + _verticalScrollbarSpacing), viewRect.sizeDelta.y);
            }
        }

        public void SetLayoutVertical()
        {
            UpdateScrollbarLayout();
            _viewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
            _contentBounds = GetBounds();
            _loopContentBounds = GetLoopBounds();
        }

        private void UpdateItem(int objectIndex, int itemIndex)
        {
            bool visible = objectIndex < _itemCount;
            
            _gameObjects[objectIndex].SetActive(visible);

            if (visible)
            {
                _gameObjects[objectIndex].GetComponent<ViewText>().SetText($"ItemIndex : {itemIndex}");
                OnUpdateItem?.Invoke(objectIndex, itemIndex);
            }
        }

        public void UpdateItems()
        {
            int itemIndex = _itemIndex;
            for (int i = 0; i < _gameObjects.Count; i++)
            {
                UpdateItem(i, itemIndex++);
            }
        }
        
        protected virtual void SetContentAnchoredPosition(Vector2 position)
        {
            if (_direction is Direction.Vertical)
            {
                TrySetLoopPosition(ref position.y);

                float delta = position.y - _content.anchoredPosition.y;
                _contentVirtualPosition.y += delta;
            }

            if (_direction is Direction.Horizontal)
            {
                TrySetLoopPosition(ref position.x);
            }
           

            if (_direction is not Direction.Horizontal)
                position.x = _content.anchoredPosition.x;
            if (_direction is not Direction.Vertical)
                position.y = _content.anchoredPosition.y;

            if (position != _content.anchoredPosition)
            {
                _content.anchoredPosition = position;
                UpdateBounds();
            }
        }

        private bool TrySetLoopPosition(ref float position)
        {
            bool isLoop = false;
            
            if (_direction is Direction.Vertical)
            {
                float top = _verticalLayoutGroup.padding.top;
                float bottom = _verticalLayoutGroup.padding.bottom;
                float spacing = _verticalLayoutGroup.spacing;
                float itemSize = _itemSize.y;
                float scrollEndPos = _content.rect.size.y - _rect.rect.size.y;

                float topBound = (itemSize + spacing) * 3 - spacing + top;
                float bottomBound = scrollEndPos - ((itemSize + spacing) * 3 - spacing + bottom);
                
                if (position > topBound)
                {
                    if (_itemIndex + _maxObjectCount < _itemCount)
                    {
                        isLoop = true;
                        float delta = position - topBound;
                        var offset = (itemSize + spacing) * 2 - spacing;

                        position = offset;
                        _prevPosition.y -= offset;
                        _contentVirtualPosition.y += topBound - offset;
                        
                        _itemIndex++;
                        int objectIndex = 0;
                        int itemIndex = _itemIndex + _maxObjectCount - 1;
                        UpdateItem(objectIndex, itemIndex);

                        var firstGameObject = _gameObjects[objectIndex];
                        firstGameObject.transform.SetSiblingIndex(_maxObjectCount - 1);
                        _gameObjects.RemoveAt(objectIndex);
                        _gameObjects.Add(firstGameObject);
                        if (_dragging)
                        {
                            _contentStartPosition.y -= itemSize;
                        }
                    }
                }
                else if (position < bottomBound)
                {
                    if (_itemIndex - 1 > -1)
                    {
                        isLoop = true;
                        float delta = position - bottomBound;
                        var offset = (itemSize + spacing) * 2 - spacing;

                        position = scrollEndPos - offset;
                        _prevPosition.y += offset;
                        _contentVirtualPosition.y -= topBound - offset;

                        _itemIndex--;
                        int objectIndex = _gameObjects.Count - 1;
                        var itemIndex = _itemIndex;
                        UpdateItem(objectIndex, itemIndex);
                    
                        var lastGameObject = _gameObjects[objectIndex];
                        lastGameObject.transform.SetSiblingIndex(0);
                        _gameObjects.RemoveAt(_maxObjectCount - 1);
                        _gameObjects.Insert(0, lastGameObject);
                    
                        if (_dragging)
                        {
                            _contentStartPosition.y += itemSize;
                        }
                    }
                }
            }

            return isLoop;
        }

        void UpdateScrollbarLayout()
        {
            if (_vSliderExpand && _horizontalScrollbar)
            {
                _tracker.Add(this, _horizontalScrollbarRect,
                    DrivenTransformProperties.AnchorMinX |
                    DrivenTransformProperties.AnchorMaxX |
                    DrivenTransformProperties.SizeDeltaX |
                    DrivenTransformProperties.AnchoredPositionX);
                _horizontalScrollbarRect.anchorMin = new Vector2(0, _horizontalScrollbarRect.anchorMin.y);
                _horizontalScrollbarRect.anchorMax = new Vector2(1, _horizontalScrollbarRect.anchorMax.y);
                _horizontalScrollbarRect.anchoredPosition = new Vector2(0, _horizontalScrollbarRect.anchoredPosition.y);
                if (vScrollingNeeded)
                    _horizontalScrollbarRect.sizeDelta = new Vector2(-(_vSliderWidth + _verticalScrollbarSpacing), _horizontalScrollbarRect.sizeDelta.y);
                else
                    _horizontalScrollbarRect.sizeDelta = new Vector2(0, _horizontalScrollbarRect.sizeDelta.y);
            }

            if (_hSliderExpand && _verticalScrollbar)
            {
                _tracker.Add(this, _verticalScrollbarRect,
                    DrivenTransformProperties.AnchorMinY |
                    DrivenTransformProperties.AnchorMaxY |
                    DrivenTransformProperties.SizeDeltaY |
                    DrivenTransformProperties.AnchoredPositionY);
                _verticalScrollbarRect.anchorMin = new Vector2(_verticalScrollbarRect.anchorMin.x, 0);
                _verticalScrollbarRect.anchorMax = new Vector2(_verticalScrollbarRect.anchorMax.x, 1);
                _verticalScrollbarRect.anchoredPosition = new Vector2(_verticalScrollbarRect.anchoredPosition.x, 0);
                if (hScrollingNeeded)
                    _verticalScrollbarRect.sizeDelta = new Vector2(_verticalScrollbarRect.sizeDelta.x, -(_hSliderHeight + _horizontalScrollbarSpacing));
                else
                    _verticalScrollbarRect.sizeDelta = new Vector2(_verticalScrollbarRect.sizeDelta.x, 0);
            }
        }

        
        private Vector2 CalculateOffset(Vector2 delta)
        {
            return InternalCalculateOffset(ref _viewBounds, ref _contentBounds, _direction, _movementType, ref delta);
        }
        
        private static float RubberDelta(float overStretching, float viewSize)
        {
            return (1 - (1 / ((Mathf.Abs(overStretching) * 0.55f / viewSize) + 1))) * viewSize * Mathf.Sign(overStretching);
        }
        
        private static Vector2 InternalCalculateOffset(ref Bounds viewBounds, ref Bounds contentBounds,Direction direction , MovementType movementType, ref Vector2 delta)
        {
            Vector2 offset = Vector2.zero;
            if (movementType == MovementType.Unrestricted)
                return offset;

            Vector2 min = contentBounds.min;
            Vector2 max = contentBounds.max;

            if (direction == Direction.Horizontal)
            {
                min.x += delta.x;
                max.x += delta.x;

                float maxOffset = viewBounds.max.x - max.x;
                float minOffset = viewBounds.min.x - min.x;

                if (minOffset < -0.001f)
                    offset.x = minOffset;
                else if (maxOffset > 0.001f)
                    offset.x = maxOffset;
            }
            else
            {
                min.y += delta.y;
                max.y += delta.y;

                float maxOffset = viewBounds.max.y - max.y;
                float minOffset = viewBounds.min.y - min.y;

                if (maxOffset > 0.001f)
                    offset.y = maxOffset;
                else if (minOffset < -0.001f)
                    offset.y = minOffset;
            }
            return offset;
        }
        
        protected void SetDirtyCaching()
        {
            if (!IsActive())
                return;

            CanvasUpdateRegistry.RegisterCanvasElementForLayoutRebuild(this);
            LayoutRebuilder.MarkLayoutForRebuild(rectTransform);
            
            // ListPool<Component>.Get();
            // LayoutUtility.GetPreferredSize(_content, 1);
            
            _viewRect = null;
        }
        
        private void UpdateBounds()
        {
            _viewBounds = new Bounds(viewRect.rect.center, viewRect.rect.size);
            _contentBounds = GetBounds();
            _loopContentBounds = GetLoopBounds();

            if (_content == null)
                return;

            Vector3 contentSize = _contentBounds.size;
            Vector3 contentPos = _contentBounds.center;
            var contentPivot = _content.pivot;
            AdjustBounds(ref _viewBounds, ref contentPivot, ref contentSize, ref contentPos);
            _contentBounds.size = contentSize;
            _contentBounds.center = contentPos;

            if (_movementType == MovementType.Clamped)
            {
                Vector2 delta = Vector2.zero;
                if (_viewBounds.max.x > _contentBounds.max.x)
                {
                    delta.x = Math.Min(_viewBounds.min.x - _contentBounds.min.x, _viewBounds.max.x - _contentBounds.max.x);
                }
                else if (_viewBounds.min.x < _contentBounds.min.x)
                {
                    delta.x = Math.Max(_viewBounds.min.x - _contentBounds.min.x, _viewBounds.max.x - _contentBounds.max.x);
                }

                if (_viewBounds.min.y < _contentBounds.min.y)
                {
                    delta.y = Math.Max(_viewBounds.min.y - _contentBounds.min.y, _viewBounds.max.y - _contentBounds.max.y);
                }
                else if (_viewBounds.max.y > _contentBounds.max.y)
                {
                    delta.y = Math.Min(_viewBounds.min.y - _contentBounds.min.y, _viewBounds.max.y - _contentBounds.max.y);
                }
                if (delta.sqrMagnitude > float.Epsilon)
                {
                    contentPos = _content.anchoredPosition + delta;

                    if (direction is Direction.Horizontal)
                    {
                        contentPos.x = _content.anchoredPosition.x;
                    }
                    else
                    {
                        contentPos.y = _content.anchoredPosition.y;
                    }
                    AdjustBounds(ref _viewBounds, ref contentPivot, ref contentSize, ref contentPos);
                }
            }
        }
        
        private readonly Vector3[] _corners = new Vector3[4];

        private Bounds GetLoopBounds()
        {
            Vector2 contentsSize = GetContentSize();

            Rect rect = this._content.rect;
            float x = rect.x;
            float y = -contentsSize.y;
            float xMax = contentsSize.x;
            float yMax = rect.yMax;
            _corners[0] = new Vector3(x, y, 0.0f);
            _corners[1] = new Vector3(x, yMax, 0.0f);
            _corners[2] = new Vector3(xMax, yMax, 0.0f);
            _corners[3] = new Vector3(xMax, y, 0.0f);

            Matrix4x4 localToWorldMatrix = _content.localToWorldMatrix;
            for (int index = 0; index < 4; ++index)
                _corners[index] = localToWorldMatrix.MultiplyPoint(_corners[index]);

            var viewWorldToLocalMatrix = viewRect.worldToLocalMatrix;
            return InternalGetBounds(_corners, ref viewWorldToLocalMatrix);
        }

        private Bounds GetBounds()
        {
            if (_content == null)
                return new Bounds();
            _content.GetWorldCorners(_corners);
            var viewWorldToLocalMatrix = viewRect.worldToLocalMatrix;
            
            return InternalGetBounds(_corners, ref viewWorldToLocalMatrix);
        }

        private Vector2 GetContentSize()
        {
            Vector2 top = Vector2.zero;
            Vector2 bottom = Vector2.zero;
            Vector2 right = Vector2.zero;
            Vector2 left = Vector2.zero;
            Vector2 totalSpacing = Vector2.zero;
            Vector2 totalItemSize = Vector2.zero;
            
            if (_direction is Direction.Vertical)
            {
                var padding = _verticalLayoutGroup.padding;
                top = Vector2.up * padding.top;
                bottom = Vector2.up * padding.bottom;
                right = Vector2.right *  padding.right;
                left = Vector2.right *  padding.left;
                totalSpacing = Vector2.up * (_verticalLayoutGroup.spacing * Mathf.Max(_itemCount - 1, 0));
                totalItemSize = Vector2.right * _contentBounds.size.x + Vector2.up * (_itemSize.y * _itemCount);
            }

            return top + bottom + right + left + totalSpacing + totalItemSize;
        }
        
        private static void UpdateOneScrollbarVisibility(bool xScrollingNeeded, bool xAxisEnabled, ScrollbarVisibility scrollbarVisibility, Scrollbar scrollbar)
        {
            if (scrollbar)
            {
                if (scrollbarVisibility == ScrollbarVisibility.Permanent)
                {
                    if (scrollbar.gameObject.activeSelf != xAxisEnabled)
                        scrollbar.gameObject.SetActive(xAxisEnabled);
                }
                else
                {
                    if (scrollbar.gameObject.activeSelf != xScrollingNeeded && xAxisEnabled)
                        scrollbar.gameObject.SetActive(xScrollingNeeded);
                }
            }
        }

        private static Bounds InternalGetBounds(Vector3[] corners, ref Matrix4x4 viewWorldToLocalMatrix)
        {
            var vMin = new Vector3(float.MaxValue, float.MaxValue, float.MaxValue);
            var vMax = new Vector3(float.MinValue, float.MinValue, float.MinValue);

            for (int j = 0; j < 4; j++)
            {
                Vector3 v = viewWorldToLocalMatrix.MultiplyPoint3x4(corners[j]);
                vMin = Vector3.Min(v, vMin);
                vMax = Vector3.Max(v, vMax);
            }

            var bounds = new Bounds(vMin, Vector3.zero);
            bounds.Encapsulate(vMax);
            return bounds;
        }

        
        private static void AdjustBounds(ref Bounds viewBounds, ref Vector2 contentPivot, ref Vector3 contentSize, ref Vector3 contentPos)
        {
            Vector3 excess = viewBounds.size - contentSize;
            if (excess.x > 0)
            {
                contentPos.x -= excess.x * (contentPivot.x - 0.5f);
                contentSize.x = viewBounds.size.x;
            }
            if (excess.y > 0)
            {
                contentPos.y -= excess.y * (contentPivot.y - 0.5f);
                contentSize.y = viewBounds.size.y;
            }
        }
    }
}
