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
    public interface ITaggedItem<out T>
    {
        T Value { get; }
        string Tag { get; }
    }

    public class TaggedItem<T> : ITaggedItem<T>
    {
        public T Value { get; private set; }
        public string Tag { get; private set; }
        public TaggedItem(T Value, string tag)
        {
            this.Value = Value;
            this.Tag = tag;
        }
    }

    public class TaggedRange : ITaggedItem<Excel.Range>
    {
        public Excel.Range Value { get; private set; }
        public string Tag { get; private set; }

        public TaggedRange(Excel.Range r, string t)
            : base()
        {
            this.Value = r;
            this.Tag = t;
        }
    }

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