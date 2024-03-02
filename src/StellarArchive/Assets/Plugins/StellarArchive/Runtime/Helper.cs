// ReSharper disable CheckNamespace

using System;
using System.Security.Cryptography;
using System.Text;
using UnityEngine;

namespace StellarArchive
{
   public static class Helper
    {
        public enum DataSizeUnit
        {
            Byte = 0,
            Kilobyte = 1,
            Megabyte = 2,
            Gigabyte = 3,
            Terabyte = 4
        }
        
        public static T GetOrAddComponent<T>(GameObject gameObject) where T : Component =>
            gameObject.TryGetComponent<T>(out var component) ? component : gameObject.AddComponent<T>();

        public static string FormatColoredString(string text, Color color)
        {
            string rgba = ColorUtility.ToHtmlStringRGBA(color);
            return FormatColoredString(text, rgba);
        }

        public static string ToIsoString(DateTime dateTime)
        {
            return dateTime.ToUniversalTime().ToString("o");
        }
        
        public static DateTime FromIsoString(string dateTimeStr)
        {
            return DateTime.Parse(dateTimeStr, null, System.Globalization.DateTimeStyles.RoundtripKind);
        }

        private static string FormatColoredString(string text, string rgba)
        {
            StringBuilder sb = new StringBuilder(text.Length);
            sb.Append("<color=#");
            sb.Append(rgba);
            sb.Append('>');
            sb.Append(text);
            sb.Append("</color>");
            return sb.ToString();
        }

        public static T GetClampedItem<T>(T[] items, int index)
        {
            if (items.Length == 0)
                return default;
            if (index < 0)
                index = 0;
            else if (index >= items.Length)
                index = items.Length - 1;
            return items[index];
        }
        
        public static T GetClampedItem<T>(T[] items, long index)
        {
            if (items.Length == 0)
                return default;
            if (index < 0)
                index = 0;
            else if (index >= items.Length)
                index = items.Length - 1;
            return items[index];
        }

        public static double ConvertBytesToHigherUnits(long bytes, out DataSizeUnit dataSizeUnit)
        {
            const int threshold = 1024;
            double resultSize = bytes;
            int unit = 0;

            while (resultSize > threshold && unit < Enum.GetNames(typeof(DataSizeUnit)).Length - 1)
            {
                resultSize /= threshold;
                unit++;
            }

            dataSizeUnit = (DataSizeUnit)unit;

            return resultSize;
        }

        public static string GenerateSHA256Base64Hash(byte[] buffer)
        {
            using var sha256 = SHA256.Create();
            byte[] encryptBytes = sha256.ComputeHash(buffer);
            return  Convert.ToBase64String(encryptBytes);;
        }
    }
}
