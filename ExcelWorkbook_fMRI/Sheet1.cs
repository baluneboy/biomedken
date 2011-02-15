﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;
using ClassLibraryFileGlobber;
using MyExcelUtilities;
using Excel = Microsoft.Office.Interop.Excel;

namespace ExcelWorkbook_fMRI
{
    [System.Runtime.InteropServices.ComVisible(true)]
    [System.Runtime.InteropServices.ClassInterface(System.Runtime.InteropServices.ClassInterfaceType.None)]

    public partial class Sheet1 : ExcelWorkbook_fMRI.ISheet1
    {
        private DataTableGrabber _dtg;
        Dictionary<string, Tuple<string, string>> _d;

        public DataTableGrabber DataTableGrabber { get { return _dtg; } }
        public string BasePathStr;
        public string MRIcroNexeStr;
        public Microsoft.Office.Tools.Excel.NamedRange ReadyIndicatorRange;
        public Microsoft.Office.Tools.Excel.NamedRange BasePathIndicatorRange;
        public Microsoft.Office.Tools.Excel.NamedRange MRIcroNexeIndicatorRange;

        private void Sheet1_Startup(object sender, System.EventArgs e)
        {
            #region Expand for comment on event handler for ANY Sheet
            //this.Application.SheetBeforeDoubleClick += new
            //    Microsoft.Office.Interop.Excel.AppEvents_SheetBeforeDoubleClickEventHandler(
            //    Application_SheetBeforeDoubleClick);
            #endregion

            this.BeforeDoubleClick += new
                Excel.DocEvents_BeforeDoubleClickEventHandler(Sheet_BeforeDoubleClick);

            // handle change event for entire Sheet1 (run)
            this.Change += new Excel.DocEvents_ChangeEventHandler(Sheet1_Change);

            // 3 indicators
            ReadyIndicatorRange = Controls.AddNamedRange(this.Range["A1"], "Ready" + "Range");  // TODO unhardcode address
            BasePathIndicatorRange = Controls.AddNamedRange(this.Range["B1"], "BasePathIndicator" + "Range");  // TODO unhardcode address
            MRIcroNexeIndicatorRange = Controls.AddNamedRange(this.Range["C1"], "MRIcroNexeIndicator" + "Range");  // TODO unhardcode address

            // Init indicators
            DimIndicators();
        }

        private void Sheet1_Shutdown(object sender, System.EventArgs e)
        {
        }

        void Sheet1_Change(Excel.Range Target)
        {
            DimIndicators();
        }

        // TODO reset (dim) the "READY" & other 2 indicators
        public void DimIndicators()
        {
            UpdateIndicator(ReadyIndicatorRange, "Dim");
            UpdateIndicator(BasePathIndicatorRange, "Dim");
            UpdateIndicator(MRIcroNexeIndicatorRange, "Dim");
        }

        // TODO not so poorly done work with indicators
        public void UpdateIndicator(Microsoft.Office.Tools.Excel.NamedRange nr, string m)
        {
            RangeFormatter rfReady = new RangeFormatter(nr.RefersToRange);
            InvokeVoidMethod(rfReady, m);
        }

        // use reflection to invoke method via string
        // see http://www.codeproject.com/KB/cs/CallMethodNameInString.aspx
        // including user comments near bottom of that page
        public static void InvokeVoidMethod(object objB, string methodName)
        {
            object obj = objB.GetType().InvokeMember(methodName,
                BindingFlags.InvokeMethod | BindingFlags.Instance | BindingFlags.Public,
                null, objB, null);
        }

        // TODO get sheet change event handler to reset (dim) the "READY" & other 2 indicators

        // this is the one we use...an event handler for THIS sheet's double-click
        void Sheet_BeforeDoubleClick(Excel.Range Target, ref bool Cancel)
        {
            Cancel = true; // affects how double-click behavior continuation goes AFTER this handler

            // we only want to take action when user double-clicks "A1" of run sheet
            if (!Target.Address.Equals("$A$1"))
                return;

            // verify basepath and exe file
            VerifyConfigPathFile();

            this.DataTableGrabber.DebugShow();
            Debug.WriteLine("#########################################");

            // loop over filter's visible range
            Excel.Range visibleCells = this.AutoFilter.Range;
            Excel.Range visibleRows = visibleCells.get_Offset(1, 0).get_Resize(visibleCells.Rows.Count - 1, 1).SpecialCells(Microsoft.Office.Interop.Excel.XlCellType.xlCellTypeVisible);

            string logstr = "";

            foreach (Excel.Range area in visibleRows.Areas)
            {
                // process each "visibly-filtered" row
                foreach (Excel.Range row in area.Rows)
                {
                    // init some strings
                    string relativeFile;
                    string overlayFile;
                    string over;
                    string abbrev;
                    string color;

                    // TODO make switches for MRIcroN call configurable in XLSM file
                    string subj = row.Value2;
                    string sess = row.get_Offset(0, 1).Value2;
                    string task = row.get_Offset(0, 2).Value2;

                    // TODO get background image [the part after task] from offset [or Tuple]
                    string globPatAnat = @BasePathStr + @"\" + subj + @"\" + sess + @"\study_*\results\" + task + @"\w2*WHOLEHEAD*.hdr";
                    FileGlobberFmriAnat fga = new FileGlobberFmriAnat(globPatAnat);
                    string anat = fga.FullName;
                    //fga.DebugShow();

                    // TODO verify other "goodness" of anat we found [how?]
                    if (!fga.IsValid)
                    {
                        logstr += "\nNo valid file like: " + globPatAnat;
                        continue;
                    }

                    abbrev = row.get_Offset(0, 3).Value2;
                    try
                    {
                        // TODO improve this ugly mess of strings here
                        relativeFile = this._d[abbrev].Item1;
                        color = this._d[abbrev].Item2;
                        overlayFile = @fga.PathAnat + relativeFile;
                        over = @" -c grayscale -o " + overlayFile + @" -b 50 -c " + color;
                    }
                    catch
                    {
                        logstr += "\ncould not handle '" + abbrev + "' as overlay for: " + globPatAnat;
                        continue;
                    }

                    // TODO verify relativeFile exists; otherwise do something graceful
                    if (!File.Exists(@fga.PathAnat + relativeFile))
                    {
                        logstr += "no overlay file: " + overlayFile;
                        continue;
                    }

                    ProcessStartInfo startInfo = new ProcessStartInfo(@MRIcroNexeStr, anat+over);
                    Process.Start(startInfo);

                }
            }
            DimIndicators();
            MessageBox.Show(logstr);
        }

        public void VerifyConfigPathFile()
        {
            // get DataTable via DataTableGrabber using named range "LookupTable"
            _dtg = new DataTableGrabber(Globals.ThisWorkbook.FullName, "LookupTable");

            // use dictionary method to get strings for basepath dir & exe file
            _d = _dtg.ToDictionaryKT();
            BasePathStr = _d["basePath"].Item1;
            MRIcroNexeStr = _d["MRIcroNexe"].Item1;

            // BasePath directory
            BasePath bp = new BasePath(BasePathStr, "Select directory for ADAT basepath.");
            BasePathStr = bp.FixPath;
            Debug.WriteLine("BasePathStr is " + BasePathStr);
            Globals.Sheet2.BasePathRange.Value2 = BasePathStr;
            UpdateIndicator(BasePathIndicatorRange, "Good");

            // MRIcroNexe file
            ExeFile ef = new ExeFile(MRIcroNexeStr, "Select exe file for MRIcroN.");
            MRIcroNexeStr = ef.FileName;
            Debug.WriteLine("MRIcroNexeStr is " + MRIcroNexeStr);
            Globals.Sheet2.MRIcroNexeRange.Value2 = MRIcroNexeStr;
            UpdateIndicator(MRIcroNexeIndicatorRange, "Good");

            UpdateIndicator(ReadyIndicatorRange, "Good");

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
