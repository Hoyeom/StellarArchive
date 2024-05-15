#if UNITY_EDITOR
using UnityEngine;

public class Info : MonoBehaviour
{
    public string description;

    public Info(string description)
    {
        this.description = description;
    }

}
#endif
