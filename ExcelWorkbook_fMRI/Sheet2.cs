using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
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
    public partial class Sheet2
    {
        Microsoft.Office.Tools.Excel.NamedRange basePathRange;
        Microsoft.Office.Tools.Excel.NamedRange MRIcroNexeRange;

        private void Sheet2_Startup(object sender, System.EventArgs e)
        {
            // This next line handled change events for entire sheet
            //this.Change += new Excel.DocEvents_ChangeEventHandler(Sheet2_Change);

            // Use this method to handle changes to (and create) named ranges for basePath & MRIcroNexe file
            NotifyChanges();
        }

        private void Sheet2_Shutdown(object sender, System.EventArgs e)
        {
        }

        private Microsoft.Office.Tools.Excel.NamedRange EstablishNamedRangeControl(string label, string address)
        {
            // TODO hunt around for label in first column rather than assuming it's at address given
            // TODO do something more graceful than clobbering when label not found

            // Verify label to the left; clobber it if needed
            string leftLabel = this.Range[address].get_Offset(0, -1).Value2;
            if (!leftLabel.Equals(label))
            {
                MessageBox.Show("was forced to clobber label for " + label);
                this.Range[address].get_Offset(0, -1).Value2 = label;
            }

            // Return named range
            return this.Controls.AddNamedRange(this.Range[address], label + "Range");
        }

        private void NotifyChanges()
        {
            // basePath
            basePathRange = EstablishNamedRangeControl("basePath", "B1");
            basePathRange.Change += new Excel.DocEvents_ChangeEventHandler(basePathRange_Change);

            // MRIcroNexe
            MRIcroNexeRange = EstablishNamedRangeControl("MRIcroNexe", "B2");
            MRIcroNexeRange.Change += new Excel.DocEvents_ChangeEventHandler(MRIcroNexeRange_Change);
        }

        void MRIcroNexeRange_Change(Excel.Range Target)
        {
            string cellAddress = Target.get_Address(missing, missing,
                Microsoft.Office.Interop.Excel.XlReferenceStyle.xlA1,
                missing, missing);
            if (!File.Exists(Target.Value2))
                MessageBox.Show("MRIcroNexe in cell " + cellAddress + " changed to non-existing file!");
            // TODO offer file dialog
        }

        void basePathRange_Change(Excel.Range Target)
        {
            string cellAddress = Target.get_Address(missing, missing,
                Microsoft.Office.Interop.Excel.XlReferenceStyle.xlA1,
                missing, missing);
            if (!Directory.Exists(Target.Value2))
                MessageBox.Show("basePath in cell " + cellAddress + " changed to non-existing path!");
            // TODO offer directory seletion dialog (defaults to pwd)
        }

        public void MaybeComplain(bool blnComplain, string msgComplaint)
        {
            if (blnComplain)
                MessageBox.Show(msgComplaint);
        }

        void Sheet2_Change(Excel.Range Target)
        {
            //// TODO verify that column to left of these Targets are labels for the dir/file of interest
            //if (Target.Column.Equals(2))
            //{
            //    if (Target.Row.Equals(1)) // basePath
            //        MaybeComplain(!Directory.Exists(Target.Value2), "basePath just entered does not exist");
            //    if (Target.Row.Equals(2)) // MRIcroNexe
            //        MaybeComplain(!File.Exists(Target.Value2), "MRIcroNexe file just entered does not exist");
            //}
        }

        #region VSTO Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(Sheet2_Startup);
            this.Shutdown += new System.EventHandler(Sheet2_Shutdown);
        }

        #endregion

    }
}