using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.IO;
using System.Windows.Forms;
// KH says the next 2 were added to accomodate COM/Excel
using Excel = Microsoft.Office.Interop.Excel;
using System.Reflection; 

namespace WindowsFormsApplication18
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            //int size = -1;
            //DialogResult result = openFileDialog1.ShowDialog(); // Show the dialog.
            //if (result == DialogResult.OK) // Test result.
            //{
            //    string file = openFileDialog1.FileName;
            //    try
            //    {
            //        string text = File.ReadAllText(file);
            //        size = text.Length;
            //    }
            //    catch (IOException)
            //    {
            //    }
            //}
            //Console.WriteLine(size); // <-- Shows file size in debugging mode.
            //Console.WriteLine(result); // <-- For debugging use only.

            this.openFileDialog1.FileName = "*.xls";
            if (this.openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                Excel.Workbook theWorkbook = ExcelObj.Workbooks.Open(
                   openFileDialog1.FileName, 0, true, 5,
                    "", "", true, Excel.XlPlatform.xlWindows, "\t", false, false,
                    0, true);
                Excel.Sheets sheets = theWorkbook.Worksheets;
                Excel.Worksheet worksheet = (Excel.Worksheet)sheets.get_Item(1);
                for (int i = 1; i <= 10; i++)
                {
                    Excel.Range range = worksheet.get_Range("A" + i.ToString(), "J" + i.ToString());
                    System.Array myvalues = (System.Array)range.Cells.Value2;
                    string[] strArray = ConvertToStringArray(myvalues);
                }
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }
    }
}