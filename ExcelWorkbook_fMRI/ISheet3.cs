using System;
namespace ExcelWorkbook_fMRI
{
    [System.Runtime.InteropServices.ComVisible(true)]
    public interface ISheet3
    {
        void CreateVstoNamedRange(Microsoft.Office.Interop.Excel.Range range, string name);
        string CreateVstoPath(string name);
    }

}
