﻿using System;
using System.Diagnostics;
using System.Windows.Forms;
using MyExcelUtilities;
using Excel = Microsoft.Office.Interop.Excel;

namespace ExcelWorkbook_fMRI
{

    public partial class ThisWorkbook
    {
        public string machineName = "";
        public Excel._Worksheet wsRun = new Excel.Worksheet();

        private void ThisWorkbook_Startup(object sender, System.EventArgs e)
        {
            Globals.Sheet7.AddLogEntry("ThisWorkbook Sheet Startup");
            
            string machineName = System.Environment.MachineName;
            Globals.Sheet7.AddLogEntry("MachineName is " + machineName);
            if (machineName.Equals("KENFX"))
            {
                Globals.Sheet2.Range["B2"].Value2 = @"E:\data\fMRI\adat";
                Globals.Sheet7.AddLogEntry("basepath specially configured for " + machineName);
            }
            ActivateRunSheet();
        }

        private void ThisWorkbook_Shutdown(object sender, System.EventArgs e)
        {
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

// TODO LIST IS HERE...
// TODO have "run" sheet's row1 (Ready, basePath, MRIcroNexe) IndicatorRanges behave better
// TODO get rid of B1 & C1 on "run" sheet [those don't really act like indicators, just use Ready]
// TODO instead of LOG sheet, use MySQL table with mechanism to query last run, run before that, etc.
// TODO mechanism to add rows to "configTable"