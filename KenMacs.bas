Attribute VB_Name = "KenMacs"
Sub CopyToNotes()
'
' CopyToNotes Macro
'
' Keyboard Shortcut: Ctrl+q
'
    Sheets("run").Activate
    Range("A2").Select
    Range(Selection, Selection.End(xlDown)).Select
    Range(Selection, Selection.End(xlToRight)).Select
    Selection.EntireRow.Select
    Selection.Copy
    Sheets("NOTES").Select
    Range("A1").Select
    Selection.End(xlDown).Offset(1, 0).Select
    ActiveSheet.Paste
    Application.CutCopyMode = False
End Sub
Public Function FileFolderExists(strFullPath As String) As Boolean
' works for both folders and files
    On Error GoTo EarlyExit
    If Not Dir(strFullPath, vbDirectory) = vbNullString Then FileFolderExists = True
    
EarlyExit:
    On Error GoTo 0

End Function
Public Sub TestFileExistence()

    If FileFolderExists("c:\temp") Then
        MsgBox "File exists!"
    Else
        MsgBox "File does not exist!"
    End If

End Sub
Sub LoopFilteredRows()

    Dim rng As Range
    Dim strFileAnat As String
    Dim strFileOver As String
    
    With ActiveSheet
     
        If Not .AutoFilterMode Then
            MsgBox "quitting--no filter"
            Exit Sub
        End If
        If Not .FilterMode Then
            MsgBox "quitting--has filters, but not filtered"
            Exit Sub
        End If
         
        Set rng = .AutoFilter.Range.Offset(1, 0).Resize(.AutoFilter.Range.Rows.Count - 1).SpecialCells(xlCellTypeVisible)
         
        For Each Row In rng.Rows
            strFileAnat = CallVSTOmethod(Row.Cells(1, 5))
            If (StrComp("(doesNotMatchOneFile)", Left(strFileAnat, 21), vbTextCompare) = 1) Then
                Debug.Print "NOT okay for " & strFileAnat
            Else
                Debug.Print "okay for " & strFileAnat
            End If
        Next Row
        
    End With
 
End Sub
Function CallVSTOmethod(strPatAnat As String) As String
    Dim VSTOSheet3 As ExcelWorkbook_fMRI.Sheet3
    Dim strNew As String
    Set VSTOSheet3 = GetManagedClass(Sheet3)
    CallVSTOmethod = VSTOSheet3.GlobAnatFile(strPatAnat)
End Function
