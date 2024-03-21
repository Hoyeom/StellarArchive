using UnityEngine;

namespace StellarArchive
{
    [CreateAssetMenu(fileName = "LoadingSetting", menuName = "StellarArchive/Settings/Loading", order = 1)]
    public class LoadingSetting : ScriptableObject
    {
        public LoadingCanvas[] loadingCanvasPrefab;
    }
}