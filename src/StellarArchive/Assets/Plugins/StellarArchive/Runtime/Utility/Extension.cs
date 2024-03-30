// ReSharper disable CheckNamespace

using UnityEngine;

namespace StellarArchive
{
    public static class Extension
    {
        public static T GetOrAddComponent<T>(this GameObject gameObject) where T : Component =>
            Helper.GetOrAddComponent<T>(gameObject);
        public static string FormatColoredString(this string text, Color color) =>
            Helper.FormatColoredString(text, color);
        public static string ToIsoString(this System.DateTime dateTime) =>
            Helper.ToIsoString(dateTime);
        public static System.DateTime FromIsoString(this string dateTimeStr) => 
            Helper.FromIsoString(dateTimeStr);
        public static T GetClampedItem<T>(this T[] items, int index) =>
            Helper.GetClampedItem(items, index);
        public static T GetClampedItem<T>(this T[] items, long index) =>
            Helper.GetClampedItem(items, index);
        public static double ConvertBytesToHigherUnits(this long bytes, out Helper.DataSizeUnit dataSizeUnit) =>
            Helper.ConvertBytesToHigherUnits(bytes, out dataSizeUnit);
    }
}