using System;
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
        public Microsoft.Office.Tools.Excel.NamedRange StatusTextRange;
        public Microsoft.Office.Tools.Excel.NamedRange StatusColumnIndicatorRange;

        private void Sheet1_Startup(object sender, System.EventArgs e)
        {
            #region Expand for comment on event handler for ANY Sheet
            //this.Application.SheetBeforeDoubleClick += new
            //    Microsoft.Office.Interop.Excel.AppEvents_SheetBeforeDoubleClickEventHandler(
            //    Application_SheetBeforeDoubleClick);
            #endregion

            Globals.Sheet7.AddLogEntry("Sheet1 Startup");

            // Handle double-click event for Sheet1 (run) -- actually, just cell "A1"
            this.BeforeDoubleClick += new
                Excel.DocEvents_BeforeDoubleClickEventHandler(Sheet_BeforeDoubleClick);

            // Handle change event for entire Sheet1 (run)
            this.Change += new Excel.DocEvents_ChangeEventHandler(Sheet1_Change);

            // Add Ready, basePath, MRIcroNexe & status text ranges
            AddIndicatorAndTextRanges();

            // Init indicators & status
            DimIndicators();
            DimStatusColumn();

            // Status text update
            UpdateStatusText("Start");
        }

        private void AddIndicatorAndTextRanges()
        {
            // add some 4 indicators
            ReadyIndicatorRange = Controls.AddNamedRange(this.Range["A1"], "Ready" + "Range");  // TODO unhardcode address
            BasePathIndicatorRange = Controls.AddNamedRange(this.Range["B1"], "BasePathIndicator" + "Range");  // TODO unhardcode address
            MRIcroNexeIndicatorRange = Controls.AddNamedRange(this.Range["C1"], "MRIcroNexeIndicator" + "Range");  // TODO unhardcode address
            StatusColumnIndicatorRange = Controls.AddNamedRange(this.Range["E:E"], "StatusColumnIndicator" + "Range");

            // add status text in cell "F1" of "run" sheet
            StatusTextRange = Controls.AddNamedRange(this.Range["F1"], "StatusText" + "Range");
        }

        public void UpdateStatusText(string s)
        {
            StatusTextRange.Value2 = DateTime.Now.ToString("F") + ": " + s;
            Globals.Sheet7.AddLogEntry(s);
        }

        private void Sheet1_Shutdown(object sender, System.EventArgs e)
        {
        }

        void Sheet1_Change(Excel.Range Target)
        {
            DimIndicators();
        }

        public void DimIndicators()
        {
            UpdateIndicator(ReadyIndicatorRange, "Dim");
            UpdateIndicator(BasePathIndicatorRange, "Dim");
            UpdateIndicator(MRIcroNexeIndicatorRange, "Dim");
        }

        public void DimStatusColumn()
        {
            UpdateIndicator(StatusColumnIndicatorRange, "Dim");
        }

        // TODO not so poorly done work with indicators
        public void UpdateIndicator(Microsoft.Office.Tools.Excel.NamedRange nr, string m)
        {
            // Use reflection to invoke "label-like" methods [why not used tagged range?]
            RangeFormatter rfReady = new RangeFormatter(nr.RefersToRange);
            InvokeVoidMethod(rfReady, m);
        }

        // This next method uses reflection to invoke method via string
        // see http://www.codeproject.com/KB/cs/CallMethodNameInString.aspx
        // including user comments near bottom of that page
        public static void InvokeVoidMethod(object objB, string methodName)
        {
            object obj = objB.GetType().InvokeMember(methodName,
                BindingFlags.InvokeMethod | BindingFlags.Instance | BindingFlags.Public,
                null, objB, null);
        }

        // Event handler for THIS sheet's double-click
        void Sheet_BeforeDoubleClick(Excel.Range Target, ref bool Cancel)
        {
            Cancel = true; // this flag affects how double-click behavior continuation goes AFTER this handler

            // we only want to take action when user double-clicks "A1" of run sheet
            if (!Target.Address.Equals("$A$1"))
            {
                Cancel = false;
                return;
            }

            // loop over visible filtered range (GetFromMacro is default abbrev there)
            LoopFilteredRange("ThisColorComesFromRunSheetColumn",action:"NOTfromMacro");
            
        }

        // a logic problem ignores the "from macro" route
        public void LoopFilteredRange(string color, string action = "GetFromMacro")
        {
            // verify basepath and exe file
            UpdateStatusText("Verifying config");
            VerifyConfigPathFile();

            // loop over filter's visible range
            Excel.Range visibleCells = this.AutoFilter.Range;
            Excel.Range visibleRows = visibleCells.get_Offset(1, 0).get_Resize(visibleCells.Rows.Count - 1, 1).SpecialCells(Microsoft.Office.Interop.Excel.XlCellType.xlCellTypeVisible);

            int count = 0;
            int countGood = 0;
            string logstr = "";
            UpdateStatusText("Stepping through each row in visible/filter range");
            foreach (Excel.Range area in visibleRows.Areas)
            {
                // process each "visibly-filtered" row
                foreach (Excel.Range row in area.Rows)
                {
                    // init some things
                    string abbrev;
                    string relativeFile;
                    string overlayFile;
                    string over;
                    //string color;
                    count++;

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
                        logstr = "bad anatomy";
                        row.get_Offset(0, 4).Value2 = logstr;
                        row.get_Offset(0, 4).Font.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Red);
                        Globals.Sheet7.AddLogEntry(logstr + " for: " + subj + " " + sess + " " + task);
                        continue;
                    }

                    try
                    {
                        // TODO improve this ugly mess of strings here
                        if (action.Equals("GetFromMacro"))
                            abbrev = action;
                        else
                        {
                            abbrev = row.get_Offset(0, 3).Value2;
                            color = this._d[abbrev].Item2;
                        }
                        Globals.Sheet7.AddLogEntry("abbrev is " + abbrev + " and color is " + color);
                        relativeFile = this._d[abbrev].Item1;
                        overlayFile = @fga.PathAnat + relativeFile;
                        over = @" -c grayscale -o " + overlayFile + @" -b 50 -c " + color;
                    }
                    catch
                    {
                        logstr = "bad overlay";
                        row.get_Offset(0, 4).Value2 = logstr;
                        row.get_Offset(0, 4).Font.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Blue);
                        Globals.Sheet7.AddLogEntry(logstr + " for: " + subj + " " + sess + " " + task);
                        continue;
                    }

                    // TODO verify relativeFile exists; otherwise do something graceful
                    if (!File.Exists(@fga.PathAnat + relativeFile))
                    {
                        logstr = "bad overlay";
                        row.get_Offset(0, 4).Value2 = logstr;
                        row.get_Offset(0, 4).Font.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Blue);
                        Globals.Sheet7.AddLogEntry(logstr + " for: " + subj + " " + sess + " " + task);
                        continue;
                    }

                    UpdateStatusText("Launching MRIcroNexe for " + subj + ", " + sess + ", " + task);
                    ProcessStartInfo startInfo = new ProcessStartInfo(@MRIcroNexeStr, anat + over);
                    Process.Start(startInfo);

                    logstr = "ok";
                    countGood++;
                    row.get_Offset(0, 4).Value2 = logstr;
                    row.get_Offset(0, 4).Font.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Green);

                }
            }
            DimIndicators();
            UpdateStatusText(String.Format("Launched MRIcroNexe for {0} 'ok' rows of {1} attempted.", countGood, count));

        }

        // BasePath directory
        public void GetBasePath(string b)
        {
            BasePath bp = new BasePath(b, "Select directory for ADAT basepath.");
            BasePathStr = bp.FixPath;
            Debug.WriteLine("BasePathStr is " + BasePathStr);
            Globals.Sheet2.BasePathRange.Value2 = BasePathStr;
            UpdateIndicator(BasePathIndicatorRange, "Good");
        }

        // MRIcroNexe file
        public void GetMRIcroNexeFile(string m)
        {
            ExeFile ef = new ExeFile(m, "Select exe file for MRIcroN.");
            MRIcroNexeStr = ef.FileName;
            Debug.WriteLine("MRIcroNexeStr is " + MRIcroNexeStr);
            Globals.Sheet2.MRIcroNexeRange.Value2 = MRIcroNexeStr;
            UpdateIndicator(MRIcroNexeIndicatorRange, "Good");
        }

        // Verify basepath and MRIcroNexe
        public void VerifyConfigPathFile()
        {
            // Get DataTable via DataTableGrabber using named range "LookupTable"
            _dtg = new DataTableGrabber(Globals.ThisWorkbook.FullName, "LookupTable");

            // Use dictionary method to get strings for basepath dir & exe file
            _d = _dtg.ToDictionaryKT();
            BasePathStr = _d["basePath"].Item1;
            MRIcroNexeStr = _d["MRIcroNexe"].Item1;

            // BasePath directory
            GetBasePath(BasePathStr);

            // MRIcroNexe file
            GetMRIcroNexeFile(MRIcroNexeStr);

            // Ready indicator
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

        #region Macros Maybe...Noooo, see Sheet7! :)

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


//string GlobAnatFile(string name);
//string RelativeOverlayFile(string pathAnat, string overlayFile);