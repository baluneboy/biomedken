using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;

namespace clipboardFiles
{
    class IniFileIO
    {
        [DllImport("kernel32.dll", EntryPoint = "GetPrivateProfileString")]
        private static extern int GetPrivateProfileString(string lpAppName, string lpKeyName, string lpDefault, StringBuilder lpReturnedString, int nSize, string lpFileName);
        [DllImport("kernel32.dll", EntryPoint = "WritePrivateProfileString")]
        private static extern bool WritePrivateProfileString(string lpAppName, string lpKeyName, string lpString, string lpFileName);

        static void ThisWasDemoMain(string[] args)
        {
            string val;
            val = GetIniValue("B", "Key1", "c:\\temp\\initest.ini");
            Console.WriteLine(val);
            WriteIniValue("B", "Key1", "New Value", "c:\\temp\\initest.ini");

            val = GetIniValue("D", "Key1", "c:\\temp\\initest.ini");
            Console.WriteLine(val);
            WriteIniValue("D", "Key1", "Value1", "c:\\temp\\initest.ini");
        }

        public static string GetIniValue(string section, string key, string filename)
        {
            int chars = 256;
            StringBuilder buffer = new StringBuilder(chars);
            string sDefault = "";
            if (GetPrivateProfileString(section, key, sDefault,
              buffer, chars, filename) != 0)
            {
                return buffer.ToString();
            }
            else
            {
                return null;
            }
        }

        public static bool WriteIniValue(string section, string key, string value, string filename)
        {
            return WritePrivateProfileString(section, key, value, filename);
        }
    }
}






