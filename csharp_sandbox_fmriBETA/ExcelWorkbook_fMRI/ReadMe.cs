//using System;
//using System.Data;
//using System.Drawing;
//using System.Windows.Forms;
//using Microsoft.VisualStudio.OfficeTools.Interop.Runtime;
//using Excel = Microsoft.Office.Interop.Excel;
//using Office = Microsoft.Office.Core;

//namespace ExcelWorkbook1
//{
//  public partial class Sheet1
//  {
//    private void Sheet1_Startup(object sender, EventArgs e)
//    {
//      this.BookList.BeforeAddDataboundRow += new
//        Microsoft.Office.Tools.Excel.BeforeAddDataboundRowHandler(
//        BookList_BeforeAddDataboundRow);

//      this.BookList.BeforeDoubleClick += new
//        Excel.DocEvents_BeforeDoubleClickEventHandler(
//        BookList_BeforeDoubleClick);


//      this.BookList.BeforeRightClick += new
//        Excel.DocEvents_BeforeRightClickEventHandler(
//        BookList_BeforeRightClick);

//      this.BookList.Change += new
//        Microsoft.Office.Tools.Excel.ListObjectChangeHandler(
//        BookList_Change);

//      this.BookList.DataBindingFailure += new
//        EventHandler(BookList_DataBindingFailure);

//      this.BookList.DataMemberChanged += new
//        EventHandler(BookList_DataMemberChanged);

//      this.BookList.DataSourceChanged += new
//        EventHandler(BookList_DataSourceChanged);

//      this.BookList.Deselected += new
//        Excel.DocEvents_SelectionChangeEventHandler(
//        BookList_Deselected);

//      this.BookList.ErrorAddDataboundRow += new
//        Microsoft.Office.Tools.Excel.ErrorAddDataboundRowHandler(
//        BookList_ErrorAddDataboundRow);

//      this.BookList.OriginalDataRestored += new
//        Microsoft.Office.Tools.Excel.OriginalDataRestoredEventHandler(
//        BookList_OriginalDataRestored);

//      this.BookList.Selected += new
//        Excel.DocEvents_SelectionChangeEventHandler(
//        BookList_Selected);

//      this.BookList.SelectedIndexChanged += new
//        EventHandler(BookList_SelectedIndexChanged);


//      this.BookList.SelectionChange += new
//        Excel.DocEvents_SelectionChangeEventHandler(
//        BookList_SelectionChange);
//    }

//    #region VSTO Designer generated code
//    private void InsternalStartup()
//    {
//      this.Startup += new EventHandler(Sheet1_Startup);
//    }

//    #endregion

//    string GetAddress(Excel.Range target, string event)
//    {

//      return String.Format("{0} {1}.",
//        target.get_Address(missing, missing,
//        Excel.XlReferenceStyle.xlA1, missing, missing),
//        event);
//    }

//    void BookList_BeforeAddDataboundRow(object sender,
//      Microsoft.Office.Tools.Excel.BeforeAddDataboundRowEventArgs e)
//    {
//      MessageBox.Show("BeforeAddDataboundRow");
//    }

//    void BookList_BeforeDoubleClick(Excel.Range target,
//      ref bool cancel)
//    {
//      MessageBox.Show(GetAddress(target, "BeforeDoubleClick"));
//    }

//    void BookList_BeforeRightClick(Excel.Range target,
//      ref bool cancel)
//    {
//      MessageBox.Show(GetAddress(target, "BeforeRightClick"));
//    }

//    void BookList_Change(Excel.Range targetRange,
//      Microsoft.Office.Tools.Excel.ListRanges changedRanges)
//    {
//      MessageBox.Show(GetAddress(targetRange, "Change"));
//    }

//    void BookList_DataBindingFailure(object sender, EventArgs e)
//    {
//      MessageBox.Show("DataBindingFailure");
//    }

//    void BookList_DataMemberChanged(object sender, EventArgs e)
//    {
//      MessageBox.Show("DataMemberChanged");
//    }

//    void BookList_DataSourceChanged(object sender, EventArgs e)
//    {
//      MessageBox.Show("DataSourceChanged");
//    }

//    void BookList_Deselected(Excel.Range target)
//    {

//      MessageBox.Show(GetAddress(target, "Deselected"));
//    }

//    void BookList_ErrorAddDataboundRow(object sender,
//      Microsoft.Office.Tools.Excel.ErrorAddDataboundRowEventArgs e)
//    {
//      MessageBox.Show("ErrorAddDataboundRow");
//    }

//    void BookList_OriginalDataRestored(object sender,
//      Microsoft.Office.Tools.Excel.OriginalDataRestoredEventArgs e)
//    {
//      MessageBox.Show("OriginalDataRestored");
//    }

//    void BookList_Selected(Excel.Range target)
//    {
//      MessageBox.Show(GetAddress(target, "Selected"));
//    }

//    void BookList_SelectedIndexChanged(object sender, EventArgs e)
//    {
//      MessageBox.Show("SelectedIndexChanged");
//    }

//    void BookList_SelectionChange(Excel.Range target)
//    {
//      MessageBox.Show(GetAddress(target, "SelectionChange"));
//    }
//  }
//}