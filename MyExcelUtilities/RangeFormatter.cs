using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Excel = Microsoft.Office.Interop.Excel;

namespace MyExcelUtilities
{
    public class RangeFormatter
    {
        protected Excel.Range rng;

        // default constructor
        public RangeFormatter() { }

        // instance constructor
        public RangeFormatter(Excel.Range r)
        {
            rng = r;
        }

        // method to format as "ready"
        public void Ready()
        {
            rng.Interior.ColorIndex = 4;
            rng.Font.Bold = true;
        }

        // method to format as "good"
        public void Good()
        {
            rng.Font.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Green);
        }

        // method to format as "dim"
        public void Dim()
        {
            rng.Font.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Gray);
        }

        // method to format as "bad"
        public void Bad()
        {
            rng.Font.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.Red);
        }
    }
}