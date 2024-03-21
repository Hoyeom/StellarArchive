using System.IO;
using System.Linq;
using Unity.Plastic.Newtonsoft.Json.Linq;
using UnityEditor;
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
        private static readonly string UniTaskGitUrl = "https://github.com/Cysharp/UniTask.git?path=src/UniTask/Assets/Plugins/UniTask";

        static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths, bool didDomainReload)
        {
            CreateScriptableObject();
        }
        static DependencyInstaller()
        {
            InstallUniTask();
            TryInstallPackage("com.unity.addressables");
        }
        
    

        private static void TryInstallPackage(string packageName)
        {
            if (!IsPackageInstalled(packageName))
            {
                InstallPackage(packageName);
            }
            
            bool IsPackageInstalled(string packageName)
            {
                var request = Client.List();
                while (!request.IsCompleted) {}

                if (request.Status == StatusCode.Success)
                {
                    foreach (var package in request.Result)
                    {
                        if (package.name == packageName)
                        {
                            return true;
                        }
                    }
                }
                else if (request.Status >= StatusCode.Failure)
                {
                    Debug.Log("패키지 목록을 가져오는 데 실패했습니다.");
                }

                return false;
            }
            
            void InstallPackage(string packageName)
            {
                Client.Add(packageName);
                Debug.Log($"{packageName} 패키지가 설치되었습니다.");
            }
        }

        public static void InstallUniTask()
        {
            if (!File.Exists(ManifestFilePath))
            {
                Debug.LogError("manifest.json not found.");
                return;
            }

            string manifestContent = File.ReadAllText(ManifestFilePath);
            var manifestJson = JObject.Parse(manifestContent);

            var dependencies = (JObject) manifestJson["dependencies"];
            if (dependencies == null)
            {
                Debug.LogError("Dependencies not found in manifest.json.");
                return;
            }

            if (dependencies.ContainsKey("com.cysharp.unitask"))
            {
                // Debug.Log("UniTask is already installed.");
                return;
            }

            dependencies["com.cysharp.unitask"] = UniTaskGitUrl;
            File.WriteAllText(ManifestFilePath, manifestJson.ToString());

            Debug.Log("UniTask installed successfully.");
            AssetDatabase.Refresh();
        }

        private static void CreateScriptableObject()
        {
            LoadingSetting asset = AssetDatabase.FindAssets($"t:{nameof(LoadingSetting)}")
                .Select(AssetDatabase.GUIDToAssetPath)
                .Select(AssetDatabase.LoadAssetAtPath<LoadingSetting>)
                .FirstOrDefault();

            if (asset == null)
            {
                asset = ScriptableObject.CreateInstance<LoadingSetting>();
                string path = AssetDatabase.GenerateUniqueAssetPath("Assets/LoadingSetting.asset");
                AssetDatabase.Refresh();
                AssetDatabase.CreateAsset(asset, path);
                AssetDatabase.SaveAssets();

                Debug.Log("LoadingSetting ScriptableObject가 생성되었습니다.");
            }
            
#if STELLARARCHIVE_ADDRESSABLE_SUPPORT
            string assetPath = AssetDatabase.GetAssetPath(asset);
            var settings = AddressableAssetSettingsDefaultObject.Settings;
            var groupName = nameof(StellarArchive);
            TryCreateNewGroup(groupName, out var group);

            if (settings.FindAssetEntry(AssetDatabase.AssetPathToGUID(assetPath)) == null)
            {
                AddressableAssetEntry entry = settings.CreateOrMoveEntry(AssetDatabase.AssetPathToGUID(assetPath), group);
                entry.address = Path.GetFileNameWithoutExtension(assetPath);
                settings.SetDirty(AddressableAssetSettings.ModificationEvent.EntryMoved, entry, true);
                AssetDatabase.SaveAssets();
            }
#endif
        }
        
        
        
#if STELLARARCHIVE_ADDRESSABLE_SUPPORT
        public static bool TryCreateNewGroup(string groupName, out AddressableAssetGroup group)
        {
            AddressableAssetSettings settings =AddressableAssetSettingsDefaultObject.GetSettings(true);
            group = null;
            
            if (settings.FindGroup(groupName) != null)
            {
                return false;
            }

            group = settings.CreateGroup(groupName, false, false, true, null);
            AssetDatabase.Refresh();
            Debug.Log($"Addressable Asset Group '{groupName}' created.");
            return true;
        }
#endif

    }
}
