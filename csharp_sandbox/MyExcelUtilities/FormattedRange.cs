using System;
using System.Drawing;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Excel = Microsoft.Office.Interop.Excel;

namespace MyExcelUtilities
{
    // TODO this really should use inheritance from Range
    public class FormattedRange:Excel.Range
    {
        protected Excel.Range rng;
        private dynamic dynamic;

        // Default constructor
        public FormattedRange()
            : base() // calls instance constructor of base class "Range"
        {
            rng = this;
        }

        public FormattedRange(dynamic dynamic)
        {
            // TODO: Complete member initialization
            this.dynamic = dynamic;
        }

        // method to format as "Good"
        public void Good()
        {
            rng.Font.Color = ColorTranslator.ToOle(Color.Green);
            rng.Font.Bold = true;
        }

        // method to format as "Bad"
        public void Bad()
        {
            rng.Font.Color = ColorTranslator.ToOle(Color.Red);
            rng.Font.Bold = true;
        }

    }
}
