using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace MyExcelUtilities
{
    public class DataTableGrabber
    {
        protected DataTable _dataTable = new DataTable();
        protected static string _workbookName;
        protected static string _namedRange;
        protected static string _connectionString;
        protected static OleDbConnection _dbConnection;

        public DataTable DataTable { get { return _dataTable; } }
        public string WorkbookName { get { return _workbookName; } }
        public string NamedRange { get { return _namedRange; } }

        // Default constructor
        public DataTableGrabber() { }

        // Instance constructor
        public DataTableGrabber(string wb, string nr)
        {
            _workbookName = wb;
            _namedRange = nr;
            _connectionString =
                    @"Provider=Microsoft.ACE.OLEDB.12.0;"
                    + @"Data Source=" + wb + ";"
                    + @"Extended Properties=""Excel 12.0;HDR=Yes;""";
            _dbConnection = new OleDbConnection(_connectionString);
            _dataTable = FillDataTableFromExcelFileNamedRange(_workbookName, _namedRange);
        }

        // method to display special dictionary
        public void DebugShow()
        {
            // Use var keyword to enumerate on "special KeyTuple" dictionary
            foreach (var pair in this.ToDictionaryKT())
            {
                Debug.WriteLine(string.Format("KEY: <{0}>, Item1: <{1}>, Item2: <{2}>",
                    pair.Key,
                    pair.Value.Item1,
                    pair.Value.Item2));
            }
        }

        // method to display special dictionary
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

        // method to convert to dictionary like (key,tuple<string,string>)
        public Dictionary<string, Tuple<string, string>> ToDictionaryKT()
        {
            // Create dictionary
            var d = new Dictionary<string, Tuple<string, string>>();

            // Loop that populates dictionary with key/value pairs
            foreach (DataRow r in _dataTable.Rows)
                d.Add(r[0].ToString(), Tuple.Create(r[1].ToString(), r[2].ToString()));

            return d;
        }

        // method to get _namedRange from excel workbook
        public static DataTable FillDataTableFromExcelFileNamedRange(string wb, string nr)
        {
            // Initialize data table
            DataTable _dataTable = new DataTable();

            // Open db connection
            _dbConnection.Open();

            // Select using named range (e.g. "LookupTable"); alternative using sheet is: "SELECT * FROM [Sheet1$]"
            try
            {
                OleDbDataAdapter dbaConfig = new OleDbDataAdapter("SELECT * FROM " + nr, _dbConnection);
                dbaConfig.Fill(_dataTable);
            }
            catch
            {
                MessageBox.Show(string.Format("problem with named range '{0}' in wb '{1}'", nr, wb));
            }
            finally
            {
                _dbConnection.Close();
            }

            return _dataTable;

        }

        //public void AdapterUpdate(int r, string s)
        //{
        //    using (OleDbConnection conn = new OleDbConnection(_connectionString))
        //    {
        //        OleDbDataAdapter dda = new OleDbDataAdapter(
        //                  "SELECT * FROM " + _namedRange, conn);

        //        Debug.WriteLine(_dataTable.Rows[0].ItemArray[0].ToString());

        //        // code to modify datatable happens here
        //        _dataTable.Rows[1]["value"] = "this really works!"; 

        //        //dda.Update(_dataTable);

        //    }
        //}

    }
}