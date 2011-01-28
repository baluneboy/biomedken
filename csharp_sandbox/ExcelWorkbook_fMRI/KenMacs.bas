Attribute VB_Name = "KenMacs"
Sub LoopFilteredRows()

    Dim rng As Range
    Dim strFileAnat As String
    Dim strFileOver As String
    Dim blnGotAnat As Boolean
    Dim blnGotOver As Boolean
    Dim RetVal As Variant

    With Sheets("run")

        If Not .AutoFilterMode Then
            MsgBox ("quitting now because no filter on 'run' sheet")
            Exit Sub
        End If
        If Not .FilterMode Then
            MsgBox ("quitting now, 'run' sheet has filters but is not filtered at all")
            Exit Sub
        End If

        Set rng = .AutoFilter.Range.Offset(1, 0).Resize(.AutoFilter.Range.Rows.Count - 1).SpecialCells(xlCellTypeVisible)

        For Each Row In rng.Rows
            strFileAnat = CallVSTOmethod(Row.Cells(1, 5))
            strFileOver = Row.Cells(1, 6)
            blnGotAnat = GotAnat(strFileAnat)
            If blnGotAnat Then
                blnGotOver = GotOver(strFileAnat, strFileOver)
                If blnGotOver Then
                    RetVal = Shell("MRIcroN.exe " & strFileAnat & " -c grayscale -o " & FilePath(strFileAnat) & strFileOver & " -b 50", 1)
                Else
                    MsgBox ("missing overlay file: " & strFileOver)
                End If
            Else
                MsgBox ("missing anatomy file: " & strFileAnat)
            End If

        Next Row

    End With

End Sub

'Sub CopyToNotes()
'    '
'    ' CopyToNotes Macro
'    '
'    ' Keyboard Shortcut: Ctrl+q
'    '
'    Sheets("run").Activate()
'    Range("A2").Select()
'    Range(Selection, Selection.End(xlDown)).Select()
'    Range(Selection, Selection.End(xlToRight)).Select()
'    Selection.EntireRow.Select()
'    Selection.Copy()
'    Sheets("NOTES").Select()
'    Range("A1").Select()
'    Selection.End(xlDown).Offset(1, 0).Select()
'    ActiveSheet.Paste()
'    Application.CutCopyMode = False
'End Sub

Public Function FileFolderExists(ByVal strFullPath As String) As Boolean
    ' Test for exist for both folders and files
    On Error GoTo EarlyExit
    If Not Dir(strFullPath, vbDirectory) = vbNullString Then FileFolderExists = True
EarlyExit:
    On Error GoTo 0
End Function
Function FileNameNoExt(ByVal strPath As String) As String
    ' Returns the filename without the extension from the file's full path:
    Dim strTemp As String
    strTemp = Mid$(strPath, InStrRev(strPath, "\") + 1)
    FileNameNoExt = Left$(strTemp, InStrRev(strTemp, ".") - 1)
End Function
Function FileNameWithExt(ByVal strPath As String) As String
    ' Returns the filename with the extension from the file's full path:
    FileNameWithExt = Mid$(strPath, InStrRev(strPath, "\") + 1)
End Function
Function FilePath(ByVal strPath As String) As String
    ' Get the path only (i.e. the folder) from the file's full path:
    FilePath = Left$(strPath, InStrRev(strPath, "\"))
End Function
Function GotOver(ByVal strFileAnat As String, ByVal strFileOver As String) As Boolean
    If FileFolderExists(FilePath(strFileAnat) & strFileOver) Then
        GotOver = True
    Else
        GotOver = False
    End If
End Function
Function GotAnat(ByVal strFileAnat As String) As Boolean
    If FileFolderExists(strFileAnat) Then
        GotAnat = True
    Else
        GotAnat = False
    End If
End Function
Function CallVSTOmethod(ByVal strPatAnat As String) As String
    Dim VSTOSheet3 As ExcelWorkbook_fMRI.Sheet3
    Dim strNew As String
    Set VSTOSheet3 = GetManagedClass(Sheet3)
    CallVSTOmethod = VSTOSheet3.GlobAnatFile(strPatAnat)
End Function
