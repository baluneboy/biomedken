using System;
using System.Collections.Generic;
using System.Windows.Forms;
using Excel = Microsoft.Office.Interop.Excel;
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
            InitializeIndicators(System.Drawing.Color.Red);
        }

        private void ThisWorkbook_Shutdown(object sender, System.EventArgs e)
        {
        }

        public void FormatAsNotFound(string str)
        {
            int r = 1;
            int c = 9;
            switch (str)
            {
                case "basePath":
                    c = 1;
                    break;
                case "MRIcroNexe":
                    c = 2;
                    break;
                case "READY":
                    c = 3;
                    break;
                default:
                    // TODO gracefully handle unexpected case
                    MessageBox.Show("gracefully handle unexpected " + str);
                    break;
            }
            wsRun.Cells[r, c].Font.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Red);
            wsRun.Cells[r, c].Font.Bold = true;
        }

        public void InitializeIndicators(System.Drawing.Color c)
        {
            FormattedRange frBasePath = new FormattedRange(wsRun.Cells[1,1]);
            Excel.Range erMRIcroNexe = wsRun.Cells[1, 2];

            // Add indicators in A1, B1 and C1
            MessageBox.Show("BEFORE Good: " + frBasePath.Column.ToString());
            frBasePath.Good();
            MessageBox.Show("AFTER Good: " + frBasePath.Column.ToString());

            erMRIcroNexe.Value2 = "MRIcroNexe";
            wsRun.Cells[1, 3] = "READY";

            // Format as "not found" (at least not yet)
            //FormatAsNotFound("basePath");
            //FormatAsNotFound("MRIcroNexe");

            // Format A1:C1 as bold [with vertical alignment = center just to show it can be done, I guess]
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
            Dictionary<string, Tuple<string, string>> d = dtg.ToDictionaryKT();
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