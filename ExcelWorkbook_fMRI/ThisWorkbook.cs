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
        private Microsoft.Office.Interop.Excel._Worksheet wsRun;
        private bool hasRunSheet;

        private void ThisWorkbook_Startup(object sender, System.EventArgs e)
        {
            // verify that we have the run sheet
            hasRunSheet = GetRunSheet();
            if (!hasRunSheet)
                MessageBox.Show("YOU NEED A SHEET NAMED \"run\" FOR THIS TO WORK CORRECTLY!\n" +
                    "PLEASE NAME THE INTENDED SHEET AS \"run\", THEN SAVE/CLOSE/REOPEN FILE.");
            wsRun.Activate();

            Microsoft.Office.Interop.Excel.Range visibleCells = wsRun.AutoFilter.Range;
            Microsoft.Office.Interop.Excel.Range visibleRows = visibleCells.get_Offset(1, 0).get_Resize(visibleCells.Rows.Count - 1, 1).SpecialCells(Microsoft.Office.Interop.Excel.XlCellType.xlCellTypeVisible, Type.Missing);
            foreach (Microsoft.Office.Interop.Excel.Range area in visibleRows.Areas)
            {
                foreach (Microsoft.Office.Interop.Excel.Range row in area.Rows)
                {
                    // process each row here
                    MessageBox.Show(row.Value2 + " " + row.get_Offset(0, 1).Value2);
                }
            }

        }

        private void ThisWorkbook_Shutdown(object sender, System.EventArgs e)
        {
        }

        // get the run sheet and set bool true
        public bool GetRunSheet()
        {
            bool bln = false;
            // HACK there has got to be a better way than looping to get this info!?
            foreach (Microsoft.Office.Interop.Excel.Worksheet ws in Globals.ThisWorkbook.Sheets)
            {
                if (ws.Name.Equals("run",StringComparison.OrdinalIgnoreCase))
                {
                    wsRun = ws;
                    bln = true;
                    break;
                }
            }
            return bln;
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
