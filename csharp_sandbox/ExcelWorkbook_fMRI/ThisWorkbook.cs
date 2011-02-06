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
            //TurnA1blue();
        }

        private void ThisWorkbook_Shutdown(object sender, System.EventArgs e)
        {
        }

        private void TurnA1blue()
        {
            Microsoft.Office.Tools.Excel.Worksheet mySheet = (Microsoft.Office.Tools.Excel.Worksheet)Sheets.get_Item("Sheet1");
            MessageBox.Show(mySheet.Range["A1"].Interior.ColorIndex);
            //mySheet.Range["A1"].Interior.ColorIndex = 3;

            //fci = ActiveCell.Range.Font.ColorIndex
            //ici = ActiveCell.Range.Interior.ColorIndex
            //pat = ActiveCell.Range.Interior.Pattern
            //nf = ActiveCell.Range.NumberFormat
            //then change the value

            //ActiveCell.Value2 = "new value"
            //and afterwards reassign the format info again

            //ActiveCell.Range.Font.ColorIndex = fci
            //ActiveCell.Range.Interior.ColorIndex = ici
            //ActiveCell.Range.Interior.Pattern = pat
            //ActiveCell.Range.NumberFormat = nf
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