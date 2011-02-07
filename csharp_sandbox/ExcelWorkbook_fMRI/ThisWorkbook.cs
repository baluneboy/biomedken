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
        public Excel._Worksheet wsRun = new Excel.Worksheet();

        private void ThisWorkbook_Startup(object sender, System.EventArgs e)
        {
            ActivateRunSheet();
            VerifyConfigPathFile();
            InitializeIndicators();
        }

        private void ThisWorkbook_Shutdown(object sender, System.EventArgs e)
        {
        }

        private void InitializeIndicators()
        {

            // Add table headers going cell by cell.
            wsRun.Cells[1, 1] = "basePath XX";
            wsRun.Cells[1, 2] = "MRIcroNexe XX";
            wsRun.Cells[1, 3] = "NOT READY";

            // Format A1:C1 as bold, red [with vertical alignment = center just to show it can be done, I guess]
            wsRun.get_Range("A1","C1").Font.Bold = true;
            wsRun.get_Range("A1", "C1").Font.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Red);
            wsRun.get_Range("C1").VerticalAlignment = Excel.XlVAlign.xlVAlignCenter;

            //MessageBox.Show(mySheet.Range["A1"].Interior.ColorIndex);
            //mySheet.Range["A1"].Interior.ColorIndex = 3;

        }

        // establish basePath & MRIcroNexe
        public void VerifyConfigPathFile()
        {
            // get DataTable via DataTableGrabber using named range "LookupTable"
            DataTableGrabber dtg = new DataTableGrabber(this.FullName, "LookupTable");  //dtg.Show();

            // use dictionary method to get basePath & exe
            Dictionary<string,Tuple<string,string>> d = dtg.ToDictionaryKT();
            basePath = d["basePath"].Item1;
            MRIcroNexe = d["MRIcroNexe"].Item2;
        }

        // get the run sheet and, if so, set bool true
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