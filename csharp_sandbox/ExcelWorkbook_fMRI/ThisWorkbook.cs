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
    public partial class ThisWorkbook
    {
        private void ThisWorkbook_Startup(object sender, System.EventArgs e)
        {
            // verify "run" sheet
            try
            {
                ((Worksheet)this.Sheets[1]).Select(missing);
            }
            catch (Exception)
            {
                
                throw;
            }
        }

        private void ThisWorkbook_Shutdown(object sender, System.EventArgs e)
        {
        }

        //private Worksheet GetWorksheetByName(string name)
        //{
        //    foreach (Excel.Worksheet ws in this.Worksheets)
        //    {
        //        if (ws.Name == name)
        //        {
        //            return ws;
        //        }
        //    }
        //    throw new ArgumentException();
        //}

        //private void ActivateWorksheetByName(string name)
        //{
        //    GetWorksheetByName(name).Activate();
        //}

        #region VSTO Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(ThisWorkbook_Startup);
            this.Shutdown += new System.EventHandler(ThisWorkbook_Shutdown);
        }

        #endregion

    }
}
