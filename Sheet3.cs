using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;
using System.IO;
using Microsoft.Office.Tools.Excel;
using Microsoft.VisualStudio.Tools.Applications.Runtime;
using Excel = Microsoft.Office.Interop.Excel;
using Office = Microsoft.Office.Core;
using ClassLibraryFileGlobber;

namespace ExcelWorkbook_fMRI
{
    [System.Runtime.InteropServices.ComVisible(true)]
    [System.Runtime.InteropServices.ClassInterface(System.Runtime.InteropServices.ClassInterfaceType.None)]

    public partial class Sheet3 : ExcelWorkbook_fMRI.ISheet3
    {
        private void Sheet3_Startup(object sender, System.EventArgs e)
        {
            //MessageBox.Show("hello3");
        }

        private void Sheet3_Shutdown(object sender, System.EventArgs e)
        {
        }

        private Microsoft.Office.Tools.Excel.NamedRange namedRange1;

        public string GlobAnatFile(string globpattern)
        {
            string str = "";
            FileGlobberFmriAnat fga = new FileGlobberFmriAnat(globpattern);
            if (fga.IsValid)
                str = fga.MatchingFiles[0].FullName;
            else
                str = "(didNotMatchOneFile)" + globpattern;
            return str;
        }

        public string RelativeOverlayFile(string pathAnat, string overlayFile)
        {
            string str = "";
            // TODO cat anatPath + relative overlayFile
            // TODO verify file exists: if yes, return cat string; otherwise, "(relativeOverlayNotExist) + catstring"
            return str;
        }

        public void CreateVstoNamedRange(Excel.Range range, string name)
        {
            if (!this.Controls.Contains(name))
            {
                namedRange1 = this.Controls.AddNamedRange(range, name);
                namedRange1.Selected += new Excel.DocEvents_SelectionChangeEventHandler(namedRange1_Selected);
            }
            else
            {
                MessageBox.Show("A named range with this specific name already exists on the worksheet.");
            }
        }

        private void namedRange1_Selected(Microsoft.Office.Interop.Excel.Range Target)
        {
            MessageBox.Show("This named range was created by Visual Studio Tools for Office.");
        }

        protected override object GetAutomationObject()
        {
            return this;
        }

        #region VSTO Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(Sheet3_Startup);
            this.Shutdown += new System.EventHandler(Sheet3_Shutdown);
        }

        #endregion

    }
}
