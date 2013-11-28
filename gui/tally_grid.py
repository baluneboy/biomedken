#!/usr/bin/env python

import sys
import wx
import wx.grid as  gridlib
import numpy as np
#import datetime
from dateutil import parser
from pims.utils.datetime_ranger import DateRange
from pims.patterns.dailyproducts import _BATCHROADMAPS_PATTERN, _PADHEADERFILES_PATTERN

# TODO add buttons to start and stop "selected/orange cells" for 2 types of threads:
#      monitor thread - disable grid interaction and just update cells every so often
#      remedy thread - how in the world do we get remedy specifics?

class CheapPadHoursInputGrid(gridlib.Grid):
    """Simple grid for inputs to a grid worker that gets results for tallying."""
    def __init__(self, parent, log, pattern=_PADHEADERFILES_PATTERN):
        gridlib.Grid.__init__(self, parent, -1)
        self.parent = parent
        self.log = log
        self.pattern = pattern
        self.get_default_values()
        self.set_default_attributes()
    
    def set_default_attributes(self):
        """Set default attributes of grid."""
        # FIXME make this dynamic, not hard-coded
        self.SetDefaultRowSize(20)
        self.SetRowLabelSize(199)            
        self.SetColLabelSize(22)
        self.SetDefaultColSize(1200)
        #self.SetDefaultRenderer(gridlib.GridCellFloatRenderer(width=6, precision=1))
        self.SetDefaultCellAlignment(wx.ALIGN_LEFT, wx.ALIGN_CENTRE)
        self.SetColLabelAlignment(wx.ALIGN_LEFT, wx.ALIGN_CENTRE)
        self.SetRowLabelAlignment(wx.ALIGN_RIGHT, wx.ALIGN_CENTRE)
    
    def get_default_values(self):
        """Gather columns_labels, row_labels, and rows for input grid defaults."""
        self.column_labels = [ 'value']
        self.rows = [
        #    row_label          default_value1
        #--------------------------------------------------
            ('start',           '2013-01-01',           parser.parse),
            ('stop',            '2013-01-04',           parser.parse),
            ('pattern',         self.pattern,           str),
            ('basepath',        '/misc/yoda/pub/pad',   str),
            ('update_sec',      '5',                    int),
            ('exclude_columns', 'None',                 lambda x: x.split(',')),
        ]
        self.row_labels = [ t[0] for t in self.rows]

    def set_row_labels(self):
        """Set the row labels."""
        for i,v in enumerate(self.row_labels):
            self.SetRowLabelValue(i, v) 

    def set_column_labels(self):
        """Set the column labels."""
        for i,v in enumerate(self.column_labels):
            self.SetColLabelValue(i, v)
            #self.SetColLabelAlignment(wx.ALIGN_RIGHT, wx.ALIGN_CENTRE) 
            
    def set_default_cell_values(self):
        """Set default cell values using values in rows."""
        # loop over rows to set cell values
        for r, rowtup in enumerate(self.rows):
            self.SetCellValue( r, 0, str(rowtup[1]) )
    
    def get_inputs(self):
        """Get inputs from cells in the grid."""
        inputs = {}
        for i,v in enumerate(self.rows):
            label, val, conv = v[0], self.GetCellValue(i, 0), v[2]
            inputs[label] = conv(val)
        return inputs

class TallyOutputGrid(gridlib.Grid):
    """Simple grid for output of tally."""
    
    def __init__(self, parent, log):
        gridlib.Grid.__init__(self, parent, -1)
        self.parent = parent
        self.log = log
        self.set_default_attributes()
        #self.CreateGrid(25, 5)

    def set_default_attributes(self):
        """Set default attributes of grid."""
        # FIXME make this dynamic, not hard-coded
        self.SetDefaultRowSize(20)
        self.SetRowLabelSize(199)            
        self.SetColLabelSize(22)
        self.SetDefaultColSize(1200)
        #self.SetDefaultRenderer(gridlib.GridCellFloatRenderer(width=6, precision=1))
        self.SetDefaultCellAlignment(wx.ALIGN_LEFT, wx.ALIGN_CENTRE)
        self.SetColLabelAlignment(wx.ALIGN_LEFT, wx.ALIGN_CENTRE)
        self.SetRowLabelAlignment(wx.ALIGN_RIGHT, wx.ALIGN_CENTRE)

    def bind_events(self):        
        self.moveTo = None
        self.Bind(wx.EVT_IDLE, self.OnIdle)
        self.EnableEditing(False)
        
        ## set default attributes of grid
        #self.SetDefaultRowSize(20)
        #self.SetRowLabelSize(99)            
        #self.SetColLabelSize(22)
        #self.SetDefaultColSize(88)
        #self.SetDefaultRenderer(gridlib.GridCellFloatRenderer(width=6, precision=1))
        #self.SetDefaultCellAlignment(wx.ALIGN_RIGHT, wx.ALIGN_CENTRE)
        
        # test all the events
        self.Bind(gridlib.EVT_GRID_CELL_LEFT_CLICK, self.OnCellLeftClick)
        self.Bind(gridlib.EVT_GRID_CELL_RIGHT_CLICK, self.OnCellRightClick)
        self.Bind(gridlib.EVT_GRID_CELL_LEFT_DCLICK, self.OnCellLeftDClick)
        self.Bind(gridlib.EVT_GRID_CELL_RIGHT_DCLICK, self.OnCellRightDClick)

        self.Bind(gridlib.EVT_GRID_LABEL_LEFT_CLICK, self.OnLabelLeftClick)
        self.Bind(gridlib.EVT_GRID_LABEL_RIGHT_CLICK, self.OnLabelRightClick)
        self.Bind(gridlib.EVT_GRID_LABEL_LEFT_DCLICK, self.OnLabelLeftDClick)
        self.Bind(gridlib.EVT_GRID_LABEL_RIGHT_DCLICK, self.OnLabelRightDClick)

        self.Bind(gridlib.EVT_GRID_ROW_SIZE, self.OnRowSize)
        self.Bind(gridlib.EVT_GRID_COL_SIZE, self.OnColSize)

        self.Bind(gridlib.EVT_GRID_RANGE_SELECT, self.OnRangeSelect)
        self.Bind(gridlib.EVT_GRID_CELL_CHANGE, self.OnCellChange)
        self.Bind(gridlib.EVT_GRID_SELECT_CELL, self.OnSelectCell)

        self.Bind(gridlib.EVT_GRID_EDITOR_SHOWN, self.OnEditorShown)
        self.Bind(gridlib.EVT_GRID_EDITOR_HIDDEN, self.OnEditorHidden)
        self.Bind(gridlib.EVT_GRID_EDITOR_CREATED, self.OnEditorCreated)

    def early_method(self, results):
        # set attributes with results
        self.row_labels = results['row_labels']
        self.column_labels = results['column_labels']
        self.rows = results['rows']
        self.exclude_columns = results['exclude_columns']
        self.update_sec = results['update_sec']
 
    def update_grid(self):
        """Write labels and values to grid."""
        # if needed, then exclude some columns
        idx_toss = []
        for xcol in self.exclude_columns:
            idx_toss += [i for i,x in enumerate(self.column_labels) if x == xcol]
        arr = np.array(self.rows)
        arr = np.delete(arr, idx_toss, axis=1)
            
        # get rid of labels for exclude columns too
        column_labels = [i for i in self.column_labels if i not in self.exclude_columns]

        ## now we have enough info to create grid
        #self.CreateGrid(arr.shape[0], arr.shape[1])
        #self.parent.output_panel.sizer.Add(self, 0, wx.EXPAND)

        # loop over array to set cell values
        for r in range(arr.shape[0]):
            self.SetRowLabelValue(r, self.row_labels[r])
            for c in range(arr.shape[1]):
                self.SetCellValue(r, c, str(arr[r][c]))
                self.SetCellTextColour(r, c, wx.BLUE)

        # set column labels
        for idx, clabel in enumerate(column_labels):
            self.SetColLabelValue(idx, clabel)
        self.SetColLabelAlignment(wx.ALIGN_RIGHT, wx.ALIGN_CENTRE)        

    def OnCellLeftClick(self, evt):
        self.log.write("OnCellLeftClick: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))
        evt.Skip()

    def OnCellRightClick(self, evt):
        self.log.write("OnCellRightClick: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))
        evt.Skip()

    def OnCellLeftDClick(self, evt):
        self.log.write("OnCellLeftDClick: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))
        evt.Skip()

    def OnCellRightDClick(self, evt):
        self.log.write("OnCellRightDClick: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))
        evt.Skip()

    def OnLabelLeftClick(self, evt):
        if evt.GetRow() == -1:
            if evt.GetCol() == -1:
                wise = 'BOTH'
                label = 'both'
            else:
                wise = 'COLUMN'
                label = self.GetColLabelValue(evt.GetCol())
        elif evt.GetCol() == -1:
            wise = 'ROW'
            label = self.GetRowLabelValue(evt.GetRow())
        else:
            wise = 'NEITHER'
            label = 'neither'
            
        self.log.write("OnLabelLeftClick: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))
        msg = "%s-WISE: %s" % (wise, label)
        self.log.write(msg + '\n')
        self.statusbar.SetStatusText(msg, SB_LEFT)
        evt.Skip()

    def OnLabelRightClick(self, evt):
        self.log.write("OnLabelRightClick: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))
        evt.Skip()

    def OnLabelLeftDClick(self, evt):
        self.log.write("OnLabelLeftDClick: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))
        evt.Skip()

    def OnLabelRightDClick(self, evt):
        self.log.write("OnLabelRightDClick: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))
        evt.Skip()

    def OnRowSize(self, evt):
        self.log.write("OnRowSize: row %d, %s\n" %
                       (evt.GetRowOrCol(), evt.GetPosition()))
        evt.Skip()

    def OnColSize(self, evt):
        self.log.write("OnColSize: col %d, %s\n" %
                       (evt.GetRowOrCol(), evt.GetPosition()))
        evt.Skip()

    def OnRangeSelect(self, evt):
        if evt.Selecting():
            msg = 'Selected'
        else:
            msg = 'Deselected'
        self.log.write("OnRangeSelect: %s  top-left %s, bottom-right %s\n" %
                           (msg, evt.GetTopLeftCoords(), evt.GetBottomRightCoords()))
        evt.Skip()

    def OnCellChange(self, evt):
        self.log.write("OnCellChange: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))

        # Show how to stay in a cell that has bad data.  We can't just
        # call SetGridCursor here since we are nested inside one so it
        # won't have any effect.  Instead, set coordinates to move to in
        # idle time.
        value = self.GetCellValue(evt.GetRow(), evt.GetCol())

        if value == 'no good':
            self.moveTo = evt.GetRow(), evt.GetCol()

    def OnIdle(self, evt):
        if self.moveTo != None:
            self.SetGridCursor(self.moveTo[0], self.moveTo[1])
            self.moveTo = None
        evt.Skip()

    def OnSelectCell(self, evt):
        if evt.Selecting():
            msg = 'Selected'
        else:
            msg = 'Deselected'
        self.log.write("OnSelectCell: %s (%d,%d) %s\n" %
                       (msg, evt.GetRow(), evt.GetCol(), evt.GetPosition()))

        # Another way to stay in a cell that has a bad value...
        row = self.GetGridCursorRow()
        col = self.GetGridCursorCol()

        if self.IsCellEditControlEnabled():
            self.HideCellEditControl()
            self.DisableCellEditControl()

        value = self.GetCellValue(row, col)

        if value == 'no good 2':
            return  # cancels the cell selection

        evt.Skip()

    def OnEditorShown(self, evt):
        if evt.GetRow() == 6 and evt.GetCol() == 3 and \
           wx.MessageBox("Are you sure you wish to edit this cell?",
                        "Checking", wx.YES_NO) == wx.NO:
            evt.Veto()
            return

        self.log.write("OnEditorShown: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))
        evt.Skip()

    def OnEditorHidden(self, evt):
        if evt.GetRow() == 6 and evt.GetCol() == 3 and \
           wx.MessageBox("Are you sure you wish to  finish editing this cell?",
                        "Checking", wx.YES_NO) == wx.NO:
            evt.Veto()
            return

        self.log.write("OnEditorHidden: (%d,%d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetPosition()))
        evt.Skip()

    def OnEditorCreated(self, evt):
        self.log.write("OnEditorCreated: (%d, %d) %s\n" %
                       (evt.GetRow(), evt.GetCol(), evt.GetControl()))

if __name__ == '__main__':
    from pims.utils.pad_hours_grid import demo
    demo()
