using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace MyExcelUtilities
{
    public class DataTableGrabber
    {
        protected static DataTable dt = new DataTable();
        protected string workbookname;
        protected string namedrange;

        public DataTable DataTable { get { return dt; } }
        public string WorkbookName { get { return workbookname; } }
        public string NamedRange { get { return namedrange; } }

        // Default constructor
        public DataTableGrabber() { }

        // Instance constructor
        public DataTableGrabber(string wb, string nr)
        {
            workbookname = wb;
            namedrange = nr;
            dt = FillDataTableFromExcelFileNamedRange(workbookname, namedrange);
        }

        // Class method to display special dictionary
        public void Show()
        {
            // Use var keyword to enumerate on "special KeyTuple" dictionary
            foreach (var pair in this.ToDictionaryKT())
            {
                MessageBox.Show(string.Format("KEY: <{0}>, Item1: <{1}>, Item2: <{2}>",
                    pair.Key,
                    pair.Value.Item1,
                    pair.Value.Item2));
            }
        }

        // Class method to convert to dictionary like (key,tuple<string,string>)
        public Dictionary<string, Tuple<string, string>> ToDictionaryKT()
        {
            // Create a well-formed dictionary
            var d = new Dictionary<string, Tuple<string, string>>();

            // Loop that populates dictionary with key/value pairs
            foreach (DataRow r in dt.Rows)
                d.Add(r[0].ToString(), Tuple.Create(r[1].ToString(), r[2].ToString()));

            return d;
        }

        // Class method to get namedrange from excel workbook
        public static DataTable FillDataTableFromExcelFileNamedRange(string wb, string nr)
        {
            // Initialize data table
            DataTable dt = new DataTable();

            // Initialize and open db connection
            OleDbConnection dbConnection = new OleDbConnection(
                    @"Provider=Microsoft.ACE.OLEDB.12.0;"
                    + @"Data Source=" + wb + ";"
                    + @"Extended Properties=""Excel 12.0;HDR=No;""");
            dbConnection.Open();

            // Select using named range, "LookupTable" (alternative using sheet is "SELECT * FROM [Sheet1$]")
            try
            {
                OleDbDataAdapter dbaConfig = new OleDbDataAdapter("SELECT * FROM " + nr, dbConnection);
                dbaConfig.Fill(dt);
            }
            finally
            {
                dbConnection.Close();
            }

            return dt;

        }
    }
}