function xlsdeletesheets(fileName)

excelObj = actxserver('Excel.Application');
excelWorkbook = excelObj.workbooks.Open(fileName);
worksheets = excelObj.sheets;
sheetIdx = 1;
sheetIdx2 = 1;
numSheets = worksheets.Count;
while sheetIdx2 <= numSheets
   sheetName = worksheets.Item(sheetIdx).Name(1:end-1);
   if ~isempty(strmatch(sheetName,'Sheet'))
      worksheets.Item(sheetIdx).Delete;
   else
      % Move to the next sheet
      sheetIdx = sheetIdx + 1;
   end
   sheetIdx2 = sheetIdx2 + 1; % prevent endless loop...
end
excelWorkbook.Save;
excelWorkbook.Close(false);
excelObj.Quit;
delete(excelObj);