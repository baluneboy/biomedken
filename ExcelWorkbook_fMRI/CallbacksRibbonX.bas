Attribute VB_Name = "CallbacksRibbonX"
Option Explicit

Dim MyFiles() As String
Dim Fnum As Long


Sub rxgal_getImage(control As IRibbonControl, ByRef returnedVal)
'This callback runs first

'It fill the array MyFiles with every jpg file in the Img folder
'You can also use png files or other picture formats,
'change *.jpg then to *.png if you use png files
'Note: name the pictures in the Img folder like "01 nameofpicture", "02 nameofpicture"
'The number will be the position of the picture in the Gallery
'Use one picture without a number for the gallery button (this will be the last picture in the array)

    Dim FilesInPath As String
    FilesInPath = Dir(ThisWorkbook.Path & "\Img\*.jpg")
    If FilesInPath = "" Then
        MsgBox "No files found"
        Exit Sub
    End If

    Fnum = 0
    Do While FilesInPath <> ""
        Fnum = Fnum + 1
        ReDim Preserve MyFiles(1 To Fnum)
        MyFiles(Fnum) = FilesInPath
        FilesInPath = Dir()
    Loop

    'Load the picture without a number in front of it from the array on the Gallery button
    'The picture without a number will automatic the last file in the array so we can use Fnum
    Set returnedVal = LoadPictureGDI(ThisWorkbook.Path & "\Img\" & MyFiles(Fnum))

End Sub

Sub rxgal_getItemCount(control As IRibbonControl, ByRef returnedVal)
'This callback runs second. It will tell the RibbonX
'how many pictures there are in the folder, we can use Fnum from the callback above
'because we use one picture for the gallery button we use -1
    returnedVal = Fnum - 1
End Sub

Sub rxgal_getItemImage(control As IRibbonControl, index As Integer, ByRef returnedVal)
'This callback runs for every picture that is in the Img folder except the picture of the gallery button
'Fnum -1 is the number of times it run this code line
    Set returnedVal = LoadPictureGDI(ThisWorkbook.Path & "\Img\" & MyFiles(index + 1))
End Sub

Sub rxgal_getItemScreentip(control As IRibbonControl, index As Integer, ByRef returnedVal)
'This callback runs for every picture that is in the Img folder except the picture of the gallery button
'Fnum -1 is the number of times it run this code line

''This will use the cell values of "A1:A?" on Sheet2 for screentips
'     returnedVal = Sheets("Sheet2").Cells(index + 1, 1).Value


'This will use the values in the array for screentips
    Dim Tipname As Variant
    Tipname = _
    Array("Tip 1", _
          "Tip 2", _
          "Tip 3", _
          "Tip 4", _
          "Tip 5", _
          "Tip 6", _
          "Tip 7", _
          "Tip 8", _
          "Tip 9")

    On Error Resume Next
    returnedVal = Tipname(index)
    On Error GoTo 0
End Sub

Sub rxgal_Click(control As IRibbonControl, id As String, index As Integer)
'Call the macro that belong to the picture when you click on one of the pictures
'For picture "01 nameofpicture" in will run the macro "macro_01"
'For picture "05 nameofpicture" in will run the macro "macro_05"
    On Error Resume Next
    Application.Run "macro_" & Format(index + 1, "00")
    On Error GoTo 0
End Sub

Sub rxbtn_Click(control As IRibbonControl)
'This code will run when you click on the button at the bottom of the Gallery
    ActiveWorkbook.FollowHyperlink "http://office.microsoft.com/en-us/default.aspx"
End Sub


'Below you find the macro's for every picture in the Gallery (9 pictures and 9 macro's)
'If you add a new picture to the Img folder with the name "10 nameofpicture" you
'must add macro with the name "macro_10" if you want to run code if you click on that picture

Sub macro_01()
    Dim RetVal
    RetVal = Shell("C:\Documents and Settings\dalyuser.FESCENTER\My Documents\programs\WinAppMyGlob.exe", 1)
End Sub
Sub macro_02()
    MsgBox "Placeholder for Macro 2 (for now)"
End Sub
Sub macro_03()
    MsgBox "Yet another placeholder for Macro 3 (for now)"
End Sub
Sub macro_04()
    MsgBox "Macro 4"
End Sub
Sub macro_05()
    MsgBox "Macro 5"
End Sub
Sub macro_06()
    MsgBox "Macro 6"
End Sub
Sub macro_07()
    MsgBox "Macro 7"
End Sub
Sub macro_08()
    MsgBox "Macro 8"
End Sub
Sub macro_09()
    MsgBox "Macro 9"
End Sub


