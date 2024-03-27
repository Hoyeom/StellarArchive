using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Serialization;

namespace StellarArchive
{
    public abstract class HamburgerCanvas : BaseCanvas
    {
        public enum PositionType
        {
            None,
            Anchor,
            Input
        }

        [FormerlySerializedAs("_root")] [field: SerializeField] private RectTransform _anchor;

        [field: SerializeField] public PositionType Type { get; private set; }
        
        private void Update()
        {
            if (Status == CanvasStatus.Open)
            {
                if (Input.GetMouseButtonDown(0))
                {
                    if (!IsClickOverUI())
                    {
                        TryCloseAsyncForget();
                    }
                }
            }
        }

        public void SetInitialPosition(RectTransform anchor)
        {
            switch (Type)
            {
                case PositionType.Anchor:
                {
                    if (anchor != null)
                    {
                        _anchor.position = anchor.position;
                    }
                    break;
                }
                case PositionType.Input:
                {
                    Vector3 inputPosition = Camera.main.ScreenToWorldPoint(Input.mousePosition);
                    inputPosition.z = _anchor.position.z;
                    _anchor.position = inputPosition;
                    break;
                }
                case PositionType.None:
                default:
                    break;
            }
        }
        
        private bool IsClickOverUI()
        {
            PointerEventData eventData = new PointerEventData(EventSystem.current);
            eventData.position = Input.mousePosition;
            List<RaycastResult> results = new List<RaycastResult>();
            EventSystem.current.RaycastAll(eventData, results);

            foreach (var result in results)
            {
                if (result.gameObject.transform.IsChildOf(transform))
                {
                    return true;
                }
            }
            return false;
        }
    }
}