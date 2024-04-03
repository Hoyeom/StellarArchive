using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class ViewText : MonoBehaviour
{
    [SerializeField] private TMP_Text _tmp;

    public void SetText(string text)
    {
        _tmp.text = text;
    }
}
