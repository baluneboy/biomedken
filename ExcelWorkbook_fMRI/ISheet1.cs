using System;
namespace ExcelWorkbook_fMRI
{
    [System.Runtime.InteropServices.ComVisible(true)]
    public interface ISheet1
    {
        void CreateVstoNamedRange(Microsoft.Office.Interop.Excel.Range range, string name);
        string GlobAnatFile(string globpattern);
    }
}
