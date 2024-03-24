using System.Collections;
using System.Collections.Generic;
using StellarArchive;
using UnityEngine;

namespace StellarArchive
{
    [CreateAssetMenu(fileName = "LoadingSetting", menuName = "StellarArchive/Settings/Loading", order = 1)]
    public class LoadingSetting : ScriptableObject
    {
        public LoadingCanvas[] loadingCanvasPrefab;
    }
}
