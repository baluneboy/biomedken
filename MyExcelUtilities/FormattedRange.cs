using System;
using System.Drawing;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Excel = Microsoft.Office.Interop.Excel;

namespace MyExcelUtilities
{
    // TODO this really should use inheritance from Range
    public class FormattedRange : Excel.Range
    {
        protected int col = 99;

        public FormattedRange(string flavor)
            :base()
        {
            // TODO: Complete member initialization
            //this.flavor = flavor;
        }

        // Explicitly implement some members of the Range interface
        public int Column
        {
            get
            {
                return col;
            }
        }

        // method to format as "Good"
        public void Good()
        {
            col = 22;
        }

        // method to format as "Bad"
        public void Bad()
        {
            
        }

    }

    #region EXAMPLE
    // Declare the English units interface:
    interface IEnglishDimensions
    {
        float Length();
        float Width();
    }

    // Declare the metric units interface:
    interface IMetricDimensions
    {
        float Length();
        float Width();
    }

    // Declare the Box class that implements the two interfaces:
    // IEnglishDimensions and IMetricDimensions:
    class Box : IEnglishDimensions, IMetricDimensions
    {
        float lengthInches;
        float widthInches;

        public Box(float length, float width)
        {
            lengthInches = length;
            widthInches = width;
        }

        // Explicitly implement the members of IEnglishDimensions:
        float IEnglishDimensions.Length()
        {
            return lengthInches;
        }

        float IEnglishDimensions.Width()
        {
            return widthInches;
        }

        // Explicitly implement the members of IMetricDimensions:
        float IMetricDimensions.Length()
        {
            return lengthInches * 2.54f;
        }

        float IMetricDimensions.Width()
        {
            return widthInches * 2.54f;
        }

        static void TEST()
        {
            // Declare a class instance box1:
            Box box1 = new Box(30.0f, 20.0f);

            // Declare an instance of the English units interface:
            IEnglishDimensions eDimensions = (IEnglishDimensions)box1;

            // Declare an instance of the metric units interface:
            IMetricDimensions mDimensions = (IMetricDimensions)box1;

            // Print dimensions in English units:
            System.Console.WriteLine("Length(in): {0}", eDimensions.Length());
            System.Console.WriteLine("Width (in): {0}", eDimensions.Width());

            // Print dimensions in metric units:
            System.Console.WriteLine("Length(cm): {0}", mDimensions.Length());
            System.Console.WriteLine("Width (cm): {0}", mDimensions.Width());
        }
    }
    #endregion
}