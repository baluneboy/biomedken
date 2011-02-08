using System;

namespace ExcelWorkbook_fMRI
{
    [System.Runtime.InteropServices.ComVisible(true)]
    public interface ISheet1
    {
        void CreateVstoNamedRange(Microsoft.Office.Interop.Excel.Range range, string name);
        string GlobAnatFile(string name);
        string RelativeOverlayFile(string pathAnat, string overlayFile);
    }

}

#region TODO
/*
 * TODO see task list items in Sheet3.cs
 * Debug.Print " >> " & FilePath(strFileAnat) & Row.Cells(1, 6)
 */
#endregion