import uno

def save_document(filename):
    ctx = uno.getComponentContext()
    smgr = ctx.ServiceManager
    desktop = smgr.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)
    calc = desktop.getCurrentComponent()    
    calc.storeAsURL('file://' + filename)

def set_cell(sheet, row, col, data):
    xCell = sheet.getCellByPosition(col, row)
    if type(data) in (type(str()), type(unicode())) : # String/Unicode type?
        xCell.setString(data)
    else:	 # assume a numeric value
        try:
            xCell.setValue(data)
        except: # ignore cells with invalid data
            print 'Invalid data ', data

def saveSheetToFile(desktop, inFile, outFile, sheetName='Sheet1'):
   
   # Make a new document
   document = desktop.loadComponentFromURL("private:factory/scalc", "_default", 0, ())
   
   # Add our new sheet
   sheets = document.getSheets()
   sheets.insertNewByName(sheetName, 0)
   sheet = document.getSheets().getByName(sheetName)
   sheet.link("file://" + inFile, sheetName, "calc8", "", NORMAL)
   
   # Break the link between the documents
   sheet.setLinkMode(NONE)
   
   # Tidy up
   removeDefaultSheets(document)
   
   # Save
   extension = outFile.split(".")[-1:][0]
   if extension == "csv":
      args = toProperties({"ReadOnly":False, "FilterName":"Text - txt - csv (StarCalc)", "FilterOptions":"59,34,76,1"})
   else:
      args = toProperties({"ReadOnly":False})
   
   document.storeToURL("file://"+outFile, args)
   
   # Close
   document.dispose()

def calc2booktab():
        ctx = uno.getComponentContext()
        smgr = ctx.ServiceManager
        desktop = smgr.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)
        doc = desktop.getCurrentComponent()
        sheet = doc.CurrentController.getActiveSheet()
        oSelection = doc.getCurrentSelection()
        oArea = oSelection.getRangeAddress()
        frow = oArea.StartRow
        lrow = oArea.EndRow
        fcol = oArea.StartColumn
        lcol = oArea.EndColumn
        oRange = sheet.getCellRangeByPosition(fcol, frow, lcol, lrow)

        #loop over selection
        newData = []
        data_list = []
        cRange = range(fcol, lcol+1)
        rRange = range(frow, lrow+1)

        # my simple test init
        out_col = 3
        out_row = 0

        for i in rRange:
                newData = []
                for j in cRange:
                        oCell = sheet.getCellByPosition(j, i)
                        seeCell = oCell.String
                        newData.append(seeCell)
                        
                        # this is where we do my simple test
                        set_cell(sheet, out_row, out_col, seeCell)
                        out_row += 1
                        
                data_list.append(newData)
                
        #save_document('/tmp/trash.ods')
        #saveSheetToFile(desktop, '/home/pims/Document/Untitled1.ods', '/tmp/trash.ods')
       
g_exportedScripts = calc2booktab,
