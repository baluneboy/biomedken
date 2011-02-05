using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;
using System.Threading;
using Microsoft.Office.Tools.Excel;
using Microsoft.VisualStudio.Tools.Applications.Runtime;
using Excel = Microsoft.Office.Interop.Excel;
using Office = Microsoft.Office.Core;
using MyExcelUtilities;

namespace ExcelWorkbook_fMRI
{

    public partial class ThisWorkbook
    {

        public string basePath;
        public string MRIcroNexe;

        private void ThisWorkbook_Startup(object sender, System.EventArgs e)
        {
            ActivateRunSheet();
            VerifyConfigPathFile();
        }

        private void ThisWorkbook_Shutdown(object sender, System.EventArgs e)
        {
        }

        // verify basePath exists
        public void VerifyConfigPathFile()
        {
            // Fill a DataTableGrabber's DataTable using named range "LookupTable" in this workbook
            DataTableGrabber dtg = new DataTableGrabber(this.FullName, "LookupTable");
            dtg.Show();
        }

        // get the run sheet and set bool true
        public void ActivateRunSheet()
        {
            Microsoft.Office.Interop.Excel._Worksheet wsRun = new Microsoft.Office.Interop.Excel.Worksheet();
            bool hasRun = false;
            // HACK there has got to be a better way than looping to get this info!?
            foreach (Microsoft.Office.Interop.Excel.Worksheet ws in Globals.ThisWorkbook.Sheets)
            {
                if (ws.Name.Equals("run", StringComparison.OrdinalIgnoreCase))
                {
                    wsRun = ws;
                    hasRun = true;
                    break;
                }
            }
            if (!hasRun)
                MessageBox.Show("YOU NEED A SHEET NAMED \"run\" FOR THIS TO WORK CORRECTLY!\n" +
                    "PLEASE NAME THE INTENDED SHEET AS \"run\", THEN SAVE/CLOSE/REOPEN FILE.");
            else
                wsRun.Activate();
        }

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