// Copyright © Microsoft Corporation.  All Rights Reserved.
// This code released under the terms of the 
// Microsoft Public License (MS-PL, http://opensource.org/licenses/ms-pl.html.)

using System;
using System.Globalization;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using System.Xml;
using Microsoft.Office.Core;
using Excel = Microsoft.Office.Interop.Excel;
using System.Diagnostics;

namespace ExcelAddInDynamicControls
{
    public static class ControlsStorage
    {
        private const string _controlsStorageNamespace = "urn:schemas-microsoft-com.VSTO2010Demos.ControlsStorage";
        private const string _rootNodeName = "ControlsStorage";
        private const string _controlsNodeName = "Controls";

        public static void Store(Excel._Workbook workbook, ControlProperties[] controls)
        {
            string xml = null;

            using (MemoryStream memStream = new MemoryStream())
            {
                BinaryFormatter formatter = new BinaryFormatter();
                formatter.Serialize(memStream, controls);

                XmlDocument doc = new XmlDocument();
                XmlElement root = doc.CreateElement(_rootNodeName, _controlsStorageNamespace);
                doc.AppendChild(root);

                XmlElement controlsDataNode = doc.CreateElement(_controlsNodeName, _controlsStorageNamespace);
                controlsDataNode.InnerXml = Convert.ToBase64String(memStream.GetBuffer(), 0, (int)memStream.Length);
                root.AppendChild(controlsDataNode);

                xml = doc.InnerXml;
            }

            CustomXMLParts parts = workbook.CustomXMLParts.SelectByNamespace(_controlsStorageNamespace);
            if (parts.Count > 0)
            {
                Debug.Assert(parts.Count == 1);
                parts[1].Delete();
            }

            workbook.CustomXMLParts.Add(xml, Type.Missing);
        }

        public static ControlProperties[] Load(Excel._Workbook workbook)
        {
            ControlProperties[] controls = null;
            CustomXMLParts parts = workbook.CustomXMLParts.SelectByNamespace(_controlsStorageNamespace);

            if (parts != null && parts.Count > 0)
            {
                Debug.Assert(parts.Count == 1);

                CustomXMLPart part = parts[1];
                XmlDocument doc = new XmlDocument();
                doc.LoadXml(part.XML);

                XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.NameTable);
                nsmgr.AddNamespace("sc", _controlsStorageNamespace);

                XmlElement controlsElement = doc.SelectSingleNode(String.Format(CultureInfo.CurrentUICulture, "//sc:{0}", _controlsNodeName), nsmgr) as XmlElement;
                if (controlsElement != null)
                {
                    byte[] data = Convert.FromBase64String(controlsElement.InnerXml);
                    BinaryFormatter formatter = new BinaryFormatter();
                    controls = (ControlProperties[])formatter.Deserialize(new MemoryStream(data));
                }
            }

            return controls;
        }
    }
}
