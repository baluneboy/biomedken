using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml.Linq;
using Microsoft.Office.Tools.Excel;
using Microsoft.VisualStudio.Tools.Applications.Runtime;
using Excel = Microsoft.Office.Interop.Excel;
using Office = Microsoft.Office.Core;
using MyExcelUtilities;

namespace ExcelWorkbookTestDataSource
{
    public partial class ThisWorkbook
    {

        private void ThisWorkbook_Startup(object sender, System.EventArgs e)
        {
            // Fill a DataTableGrabber's DataTable using named range "LookupTable" in this workbook
            DataTableGrabber dtg = new DataTableGrabber(this.FullName,"LookupTable");

            // Use var keyword to enumerate on "special KeyTuple" dictionary
            foreach (var pair in dtg.ToDictionaryKT())
            {
                MessageBox.Show(string.Format("{0}, {1}, {2}",
                    pair.Key,
                    pair.Value.Item1,
                    pair.Value.Item2));
            }

        }

        private void ThisWorkbook_Shutdown(object sender, System.EventArgs e)
        {
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

        //public DataTable FillDataTableFromExcelFileNamedRange(string wb)
        //{
        //    // Initialize data table
        //    DataTable dt = new DataTable();

        //    // Initialize and open db connection
        //    OleDbConnection dbConnection = new OleDbConnection(
        //            @"Provider=Microsoft.ACE.OLEDB.12.0;"
        //            + @"Data Source=" + wb + ";"
        //            + @"Extended Properties=""Excel 12.0;HDR=No;""");
        //    dbConnection.Open();

        //    // Select using named range, "LookupTable" (alternative using sheet is "SELECT * FROM [Sheet1$]")
        //    try
        //    {
        //        OleDbDataAdapter dbaConfig = new OleDbDataAdapter("SELECT * FROM LookupTable", dbConnection);
        //        dbaConfig.Fill(dt);
        //    }
        //    finally
        //    {
        //        dbConnection.Close();
        //    }

        //    return dt;

        //}
    }
}