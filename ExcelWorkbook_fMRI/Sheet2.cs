using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
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
    public partial class Sheet2
    {
        private void Sheet2_Startup(object sender, System.EventArgs e)
        {
            this.Change += new Excel.DocEvents_ChangeEventHandler(Sheet2_Change);
        }

        private void Sheet2_Shutdown(object sender, System.EventArgs e)
        {
        }

        void Sheet2_Change(Excel.Range Target)
        {
            if (Target.Row.Equals(2))
                if (Target.Column.Equals(1)) // basePath
                    if (!Directory.Exists(Target.Value2))
                        MessageBox.Show("basePath in " + this.Name + " row " + Target.Row + " " + ", column " + Target.Column + " changed to path I could not find.","PROBLEM");
                if (Target.Column.Equals(2)) // MRIcroNexe
                    if (!File.Exists(Target.Value2))
                        MessageBox.Show("MRIcroNexe in " + this.Name + " row " + Target.Row + " " + ", column " + Target.Column + " changed to path/file I could not find.", "PROBLEM");
        }

        #region VSTO Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(Sheet2_Startup);
            this.Shutdown += new System.EventHandler(Sheet2_Shutdown);
        }

        #endregion

    }
}
