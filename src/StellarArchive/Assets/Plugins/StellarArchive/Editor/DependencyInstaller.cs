using System;
using System.IO;
using System.Linq;
using Unity.Plastic.Newtonsoft.Json.Linq;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.PackageManager;
using UnityEngine;

#if STELLARARCHIVE_ADDRESSABLE_SUPPORT
using UnityEditor.AddressableAssets;
using UnityEditor.AddressableAssets.Settings;
#endif

namespace StellarArchive.Editor
{
    [InitializeOnLoad]
    public class DependencyInstaller : AssetPostprocessor
    {
        private static readonly string ManifestFilePath = Path.Combine(Application.dataPath, "../Packages/manifest.json");
        private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets,
            string[] movedFromAssetPaths)
        {
            CreateScriptableObject<LoadingSetting>();
        }

        static DependencyInstaller()
        {
            InstallPackage("com.cysharp.unitask", "https://github.com/Cysharp/UniTask.git?path=src/UniTask/Assets/Plugins/UniTask");
            InstallPackage("com.unity.addressables");
            
        }
        
        public static void InstallPackage(string packageName, string gitUrl = null)
        {
            if (!File.Exists(ManifestFilePath))
            {
                Debug.LogError("manifest.json not found.");
                return;
            }

            string manifestContent = File.ReadAllText(ManifestFilePath);
            JObject manifestJson = JObject.Parse(manifestContent);
            JObject dependencies = (JObject) manifestJson["dependencies"];
                
            if (dependencies == null)
            {
                Debug.LogError("Dependencies not found in manifest.json.");
                return;
            }

            if (dependencies.ContainsKey(packageName))
            {
                Debug.Log($"{packageName} is already installed.");
                return;
            }
                
            dependencies[packageName] = string.IsNullOrWhiteSpace(gitUrl) ? packageName : gitUrl;
            File.WriteAllText(ManifestFilePath, manifestJson.ToString());

            Debug.Log($"{packageName} installed successfully.");
            AssetDatabase.Refresh();
        }

        private static void CreateScriptableObject<T>() where T : ScriptableObject
        {
            var typeName = typeof(T).Name;
                
            var path = AssetDatabase.FindAssets($"t:{typeName}")
                .Select(AssetDatabase.GUIDToAssetPath)
                .FirstOrDefault();
            
            if(!string.IsNullOrWhiteSpace(path))
                return;
            
            path = $"Assets/{typeName}.asset";
            
            T asset = AssetDatabase.LoadAssetAtPath<T>(path);

            if (asset == null)
            {
                asset = ScriptableObject.CreateInstance<T>();
                path = AssetDatabase.GenerateUniqueAssetPath(path);
                AssetDatabase.CreateAsset(asset, path);
                AssetDatabase.SaveAssets();

                Debug.Log($"{typeName} ScriptableObject가 생성되었습니다.");
                EditorUtility.FocusProjectWindow();

                Selection.activeObject = asset;
            }
#if STELLARARCHIVE_ADDRESSABLE_SUPPORT
            string assetPath = AssetDatabase.GetAssetPath(asset);
            var groupName = nameof(StellarArchive);
            TryCreateNewGroup(groupName, out var group);
            var settings = AddressableAssetSettingsDefaultObject.Settings;

            if (settings.FindAssetEntry(AssetDatabase.AssetPathToGUID(assetPath)) == null)
            {
                AddressableAssetEntry entry = settings.CreateOrMoveEntry(AssetDatabase.AssetPathToGUID(assetPath), group);
                AssetDatabase.Refresh();

                if (entry != null)
                {
                    entry.address = Path.GetFileNameWithoutExtension(assetPath);
                    settings.SetDirty(AddressableAssetSettings.ModificationEvent.EntryMoved, entry, true);
                }
            }
#endif
        }
        
#if STELLARARCHIVE_ADDRESSABLE_SUPPORT
        public static bool TryCreateNewGroup(string groupName, out AddressableAssetGroup group)
        {
            AddressableAssetSettings settings = AddressableAssetSettingsDefaultObject.Settings;
            if (settings == null)
                settings =AddressableAssetSettingsDefaultObject.GetSettings(true);
            group = settings.FindGroup(groupName);
            
            if (group != null)
                return false;

            group = settings.CreateGroup(groupName, false, false, true, null);
            AssetDatabase.Refresh();
            Debug.Log($"Addressable Asset Group '{groupName}' created.");
            return true;
        }
#endif

    }
}
