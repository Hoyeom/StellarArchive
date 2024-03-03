using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.PackageManager;
using UnityEngine;

namespace StellarArchive.Editor
{
    [InitializeOnLoad]
    public class DependencyInstaller
    {
        static DependencyInstaller()
        {
            var request = Client.List();
            while (!request.IsCompleted) {}

            if (request.Status == StatusCode.Success)
            {
                bool isAddressablesInstalled = false;
                foreach (var package in request.Result)
                {
                    if (package.name == "com.unity.addressables")
                    {
                        isAddressablesInstalled = true;
                        break;
                    }
                }

                if (!isAddressablesInstalled)
                {
                    Client.Add("com.unity.addressables");
                    Debug.Log("패키지 생성");
                }
            }
            else if (request.Status >= StatusCode.Failure)
            {
                Debug.Log("패키지 목록을 가져오는 데 실패했습니다.");
            }
            
            // CreateScriptableObject();
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
                AssetDatabase.CreateAsset(asset, path);
                AssetDatabase.SaveAssets();

                Debug.Log("LoadingSetting ScriptableObject 생성됨.");
            }
        }
    }
}