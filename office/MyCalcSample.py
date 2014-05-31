import uno

def save_document(filename):
    ctx = uno.getComponentContext()
    smgr = ctx.ServiceManager
    desktop = smgr.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)
    calc = desktop.getCurrentComponent()    
    calc.storeAsURL('file://' + filename, ())

def set_cell(sheet, row, col, data):
    xCell = sheet.getCellByPosition(col, row)
    if type(data) in (type(str()), type(unicode())) : # String/Unicode type?
        xCell.setString(data)
    else:	 # assume a numeric value
        try:
            xCell.setValue(data)
        except: # ignore cells with invalid data
            print 'Invalid data ', data

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

        ###########################################
        # Init for my simple test.
        out_col = 3
        out_row = 0
        ###########################################

        for i in rRange:
                newData = []
                for j in cRange:
                        oCell = sheet.getCellByPosition(j, i)
                        seeCell = oCell.String
                        newData.append(seeCell)
                        
                        ###########################################
                        # This is where we do my simple test.
                        set_cell(sheet, out_row, out_col, seeCell)
                        out_row += 1
                        ###########################################
                        
                data_list.append(newData)
                
        save_document( '/tmp/trashbigtime.ods' )
       
g_exportedScripts = calc2booktab,
