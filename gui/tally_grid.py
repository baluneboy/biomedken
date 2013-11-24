#!/usr/bin/env python

import datetime
import wx
import wx.grid as  gridlib

# TODO use 2-panels: (1) input grid, and (2) output grid
#
# TODO add buttons to start and stop "selected/orange cells" for 2 types of threads:
#      monitor thread - disable grid interaction and just update cells every so often
#      remedy thread - how in the world do we get remedy specifics?

# Status bar constants
SB_LEFT = 0
SB_RIGHT = 1

class TallyGrid(gridlib.Grid):
    """Simple grid for tallying."""
    
    def __init__(self, parent, log, grid_worker, exclude_columns=[], update_sec=30):
        gridlib.Grid.__init__(self, parent, -1)
        self.log = log
        self.grid_worker = grid_worker
        self.row_labels = grid_worker.row_labels
        self.column_labels = grid_worker.column_labels
        self.rows = grid_worker.rows
        self.exclude_columns = exclude_columns
        self.update_sec = update_sec
        self.moveTo = None
        self.Bind(wx.EVT_IDLE, self.OnIdle)
        
        self.CreateGrid(len(self.row_labels), len(self.column_labels))
        self.EnableEditing(False)
        
        # set default attributes of grid
        self.SetDefaultRowSize(20)
        self.SetRowLabelSize(99)            
        self.SetColLabelSize(22)
        self.SetDefaultColSize(88)
        self.SetDefaultRenderer(gridlib.GridCellFloatRenderer(width=6, precision=1))
        self.SetDefaultCellAlignment(wx.ALIGN_RIGHT, wx.ALIGN_CENTRE)
        
        ## loop over self.rows to set cell values
        #for r in range(len(self.rows)):
        #    self.SetRowLabelValue(r, self.row_labels[r])
        #    for c in range(len(self.rows[r])):
        #        self.SetCellValue(r, c, str(self.rows[r][c]))
        #        self.SetCellTextColour(r, c, wx.BLUE)
        #
        ## if needed, then exclude some columns
        #for ex_col in exclude_columns:
        #    # get rid of columns that have ex_col as label
        #    idx_none_cols = [i for i,x in enumerate(self.column_labels) if x == ex_col]
        #    for idx in idx_none_cols:
        #        self.DeleteCols(idx)
        #    # get rid of 'None' labels too
        #    self.column_labels = [i for i in self.column_labels if i != ex_col]
        #
        ## set column labels
        #for idx, clabel in enumerate(self.column_labels):
        #    self.SetColLabelValue(idx, clabel)
        #self.SetColLabelAlignment(wx.ALIGN_RIGHT, wx.ALIGN_CENTRE)
        self.update_grid()

        #print self.GetRowSize(0), self.GetColSize(0)

        ## attribute objects let you keep a set of formatting values
        ## in one spot, and reuse them if needed
        #_NORMAL_ATTR = gridlib.GridCellAttr()
        #_NORMAL_ATTR.SetTextColour(wx.BLACK)
        #_NORMAL_ATTR.SetBackgroundColour(wx.WHITE)
        #_NORMAL_ATTR.SetFont(wx.Font(10, wx.SWISS, wx.NORMAL, wx.NORMAL))
        #
        ### you can set cell attributes for the whole row (or column)
        #self.SetColAttr(1, _NORMAL_ATTR)
        
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

        # Status bar
        self.statusbar = parent.CreateStatusBar(2, 0)        
        self.statusbar.SetStatusWidths([-1, 320])
        self.statusbar.SetStatusText("Ready", SB_LEFT)
        
        # Set up a timer to update the date/time (every few seconds)
        self.timer = wx.PyTimer(self.notify)
        self.timer.Start( int(self.update_sec * 1000) )
        self.notify() # call it once right away

    def update_grid(self):
        """Write labels and values to grid."""
        # loop over self.rows to set cell values
        for r in range(len(self.rows)):
            self.SetRowLabelValue(r, self.row_labels[r])
            for c in range(len(self.rows[r])):
                self.SetCellValue(r, c, str(self.rows[r][c]))
                self.SetCellTextColour(r, c, wx.BLUE)

        # if needed, then exclude some columns
        for ex_col in self.exclude_columns:
            # get rid of columns that have undesired label
            idx_none_cols = [i for i,x in enumerate(self.column_labels) if x == ex_col]
            for idx in idx_none_cols:
                self.DeleteCols(idx)
            # get rid of 'None' labels too
            self.column_labels = [i for i in self.column_labels if i != ex_col]

        # set column labels
        for idx, clabel in enumerate(self.column_labels):
            self.SetColLabelValue(idx, clabel)
        self.SetColLabelAlignment(wx.ALIGN_RIGHT, wx.ALIGN_CENTRE)        

    def get_time_str(self):
        return datetime.datetime.now().strftime('%d-%b-%Y,%j/%H:%M:%S ')

    def notify(self):
        """Timer event updated every so often."""
        self.update_grid()
        t = self.get_time_str() + ' (update every ' + str(int(self.update_sec)) + 's)'
        self.statusbar.SetStatusText(t, SB_RIGHT)

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

class TallyFrame(wx.Frame):
    """The main window (frame) that contains the tally grid."""
    def __init__(self, parent, log, grid_worker, exclude_columns=[], update_sec=20):
        wx.Frame.__init__(self, parent, -1, grid_worker.title)
        self.Maximize(True)
        self.grid = TallyGrid(self, log, grid_worker,
                              exclude_columns=exclude_columns, update_sec=update_sec)

class DummyGridWorker(object):
    
    def __init__(self):
        self.title = 'Demo Tally'
        self.row_labels = ['2013-10-31', '2013-11-01']
        self.column_labels = ['hirap','121f03','121f05onex']
        self.rows = [ [0.0, 0.5, 1.0], [0.9, 0.4, 0.2] ]        

def demo():
    import sys
    grid_worker = DummyGridWorker()
    # run main loop
    app = wx.PySimpleApp()
    frame = TallyFrame(None, sys.stdout, grid_worker,
                       exclude_columns=[], update_sec=5) # update normally 30
    frame.Show(True)
    app.MainLoop()

if __name__ == '__main__':
    demo()
