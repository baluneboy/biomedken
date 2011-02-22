using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;
using Microsoft.Office.Tools.Excel;
using Microsoft.VisualStudio.Tools.Applications.Runtime;
using Excel = Microsoft.Office.Interop.Excel;
using Office = Microsoft.Office.Core;

namespace ExcelWorkbook_fMRI
{
    public partial class Sheet7
    {
        private void Sheet7_Startup(object sender, System.EventArgs e)
        {
            AddLogEntry(this.Name + " Sheet Startup");
        }

        private void Sheet7_Shutdown(object sender, System.EventArgs e)
        {
        }

        public void AddLogEntry(string s)
        {
			// TODO the next 2 things is what...
            // TODO if first word of s is "bad", then Font.Color is red
            // TODO if first word of s is "Launched", then EntireRow is highlighted
            Excel.Range range = (Excel.Range)Globals.Sheet7.Range["A2"].EntireRow;
            range.Insert(Excel.XlInsertShiftDirection.xlShiftDown);
            Globals.Sheet7.Range["A2"].Value2 = DateTime.Now.ToString("F");
            Globals.Sheet7.Range["B2"].Value2 = s;
        }

        #region VSTO Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(Sheet7_Startup);
            this.Shutdown += new System.EventHandler(Sheet7_Shutdown);
        }

        #endregion

    }
}
