using System;
using Cysharp.Threading.Tasks;
using UnityEngine;

namespace StellarArchive.Sample
{
    public class SampleTouchEffect : MonoBehaviour
    {
        [SerializeField] private ParticleSystem _particleSystem;
        private ParticleSystem.EmitParams _emitSettings;

        private void Start()
        {
            _emitSettings = new ParticleSystem.EmitParams();
        }

        private void Update()
        {
            if (Input.GetMouseButtonDown(0))
            {
                var pos = Camera.main.ScreenToWorldPoint(Input.mousePosition);
                pos.z = 0f;
                _emitSettings.position = pos;
                _particleSystem.Emit(_emitSettings, 1);
            }
        }
    }
}
