using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;
using System.IO;
using System.Diagnostics;
using System.Threading;
using Microsoft.Office.Tools.Excel;
using Microsoft.VisualStudio.Tools.Applications.Runtime;
using Excel = Microsoft.Office.Interop.Excel;
using Office = Microsoft.Office.Core;
using ClassLibraryFileGlobber;
using MyExcelUtilities;

namespace ExcelWorkbook_fMRI
{
    [System.Runtime.InteropServices.ComVisible(true)]
    [System.Runtime.InteropServices.ClassInterface(System.Runtime.InteropServices.ClassInterfaceType.None)]

    public partial class Sheet1 : ExcelWorkbook_fMRI.ISheet1
    {

        public string BasePathStr;
        public string MRIcroNexeStr;

        private void Sheet1_Startup(object sender, System.EventArgs e)
        {
            #region Expand for comment on event handler for ANY Sheet
            //this.Application.SheetBeforeDoubleClick += new
            //    Microsoft.Office.Interop.Excel.AppEvents_SheetBeforeDoubleClickEventHandler(
            //    Application_SheetBeforeDoubleClick);
            #endregion

            this.BeforeDoubleClick += new
                Excel.DocEvents_BeforeDoubleClickEventHandler(Sheet_BeforeDoubleClick);
        }

        private void Sheet1_Shutdown(object sender, System.EventArgs e)
        {
        }

        // Event handler for THIS sheet
        void Sheet_BeforeDoubleClick(Excel.Range Target, ref bool Cancel)
        {
            Cancel = true; // affects how double-click behavior continuation goes AFTER this handler

            // early return when "A1" is not double-click's target
            if (!Target.Address.Equals("$A$1"))
                return;

            // loop over filter's visible range
            Excel.Range visibleCells = this.AutoFilter.Range;
            Excel.Range visibleRows = visibleCells.get_Offset(1, 0).get_Resize(visibleCells.Rows.Count - 1, 1).SpecialCells(Microsoft.Office.Interop.Excel.XlCellType.xlCellTypeVisible);
            foreach (Excel.Range area in visibleRows.Areas)
            {
                // process each "visibly-filtered" row
                foreach (Excel.Range row in area.Rows)
                {

                    // TODO make switches for MRIcroN call configurable in XLSM file
                    string subj = row.Value2;
                    string sess = row.get_Offset(0, 1).Value2;
                    string task = row.get_Offset(0, 2).Value2;

                    // TODO get basePath from named range
                    string globPatAnat = @"y:\adat\" + subj + @"\" + sess + @"\study_*\results\" + task + @"\w2*WHOLEHEAD*.hdr";
                    FileGlobberFmriAnat fga = new FileGlobberFmriAnat(globPatAnat);
                    string anat = fga.FileAnat;

                    // TODO get overlay,color from Tuple of"grabber"
                    string over = @" -c grayscale -o " + row.get_Offset(0, 5).Value2 + @" -b 50";

                    // TODO get MRIcroNexe from named range
                    Process p = new Process();
                    p.StartInfo.FileName = @"C:\Program Files\mricron\MRIcroN.exe";
                    p.StartInfo.Arguments = anat + over;
                    p.Start();

                }
            }
        }

        public void VerifyConfigPathFile()
        {

            // get DataTable via DataTableGrabber using named range "LookupTable"
            DataTableGrabber dtg = new DataTableGrabber(Globals.ThisWorkbook.FullName, "LookupTable");
            dtg.DebugShow();
            //dtg.AdapterUpdate(1,"s");

            // use dictionary method to get strings for basepath dir & exe file
            Dictionary<string, Tuple<string, string>> d = dtg.ToDictionaryKT();
            BasePathStr = d["basePath"].Item1;
            MRIcroNexeStr = d["MRIcroNexe"].Item1;
            Debug.WriteLine(@"DataTableGrabber gives us MRIcroNexeStr to be >" + MRIcroNexeStr + "<");

            // BasePath directory
            BasePath bp = new BasePath(BasePathStr, "Select directory for ADAT basepath.");
            BasePathStr = bp.FixPath;
            Debug.WriteLine("BasePathStr is " + BasePathStr);
            // now stuff the bloody basepath string into its cell

            // MRIcroNexe file
            ExeFile ef = new ExeFile(MRIcroNexeStr, "Select exe file for MRIcroN.");
            MRIcroNexeStr = ef.FileName;
            Debug.WriteLine("MRIcroNexeStr is " + MRIcroNexeStr);

        }

        #region Expand for comment on event handler for ANY Sheet
        // The following applies to event for ANY sheet
        //void Application_SheetBeforeDoubleClick(object Sh,
        //    Microsoft.Office.Interop.Excel.Range Target, ref bool Cancel)
        //{
        //    Cancel = true;
        //    //MessageBox.Show("Double click");
        //    Microsoft.Office.Interop.Excel.Range visibleCells = this.AutoFilter.Range;
        //    Microsoft.Office.Interop.Excel.Range visibleRows = visibleCells.get_Offset(1, 0).get_Resize(visibleCells.Rows.Count - 1, 1).SpecialCells(Microsoft.Office.Interop.Excel.XlCellType.xlCellTypeVisible);
        //    foreach (Microsoft.Office.Interop.Excel.Range area in visibleRows.Areas)
        //    {
        //        foreach (Microsoft.Office.Interop.Excel.Range row in area.Rows)
        //        {
        //            // process each row here
        //            MessageBox.Show(row.Value2 + " " + row.get_Offset(0, 1).Value2);
        //        }
        //    }
        //}
        #endregion

        #region NOT OBSOLETE (yet...)

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
        #endregion

        #region VSTO Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(Sheet1_Startup);
            this.Shutdown += new System.EventHandler(Sheet1_Shutdown);
        }

        #endregion

    }
}
