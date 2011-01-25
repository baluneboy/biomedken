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

#region TODO
/*
 * derive FileGlobberFmriAnat class that does not use FileInfo iterator, but SINGLE FileInfo with convenience attributes
 * the above plays into the following
 * string method to return basepath of anat file
 * string method to return filename of anat file
 */
#endregion