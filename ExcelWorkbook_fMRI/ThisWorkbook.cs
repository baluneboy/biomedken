using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Windows.Forms;
using Excel = Microsoft.Office.Interop.Excel;
using MyExcelUtilities;
using ClassLibraryFileGlobber;

namespace ExcelWorkbook_fMRI
{

    public partial class ThisWorkbook
    {

        public Excel._Worksheet wsRun = new Excel.Worksheet();

        private void ThisWorkbook_Startup(object sender, System.EventArgs e)
        {
            if (Debugger.IsAttached)
            {
                MessageBox.Show("HOME USAGE");
                Excel.Range HOMEBP = Globals.Sheet2.Cells[2, 2];
                HOMEBP.Value = @"F:\Data\";
            }
            ActivateRunSheet();
            //VerifyConfigPathFile();
            //UpdateIndicators();
        }

        private void ThisWorkbook_Shutdown(object sender, System.EventArgs e)
        {
        }

        public void UpdateIndicators()
        {
            RangeFormatter rfReady = new RangeFormatter(wsRun.Cells[1, 1]);
            RangeFormatter rfBasePath = new RangeFormatter(wsRun.Cells[1, 2]);
            RangeFormatter rfMRIcroNexe = new RangeFormatter(wsRun.Cells[1, 3]);

            // modify indicators along top row of run sheet
            rfBasePath.Bad();
            rfMRIcroNexe.Bad();
            rfReady.Dim();
            //rfReady.Ready();
        }
                
        // activate run sheet (hopefully)
        public void ActivateRunSheet()
        {

            bool hasRun = false;
            // HACK there has got to be a better way than looping to get this info!?
            foreach (Excel.Worksheet ws in Globals.ThisWorkbook.Sheets)
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