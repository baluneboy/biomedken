#!/usr/bin/env python

import datetime
import wx
import wx.grid as  gridlib

# TODO move status bar init to TestFrame (not in grid class)
# TODO add buttons to start and stop "selected/orange cells" thread

# Status bar constants
SB_LEFT = 0
SB_RIGHT = 1
SB_MSEC = 20000

class ThirdsCellFormatRGY(object):
    """Less 1/3 is white-on-red, greater than 2/3 is black-on-green; otherwise, black-on-yellow."""
    def __init__(self, value):
        self.value = value
        self.bg_color, self.fg_color = self._get_colors()
    
    def _get_colors(self):
        if self.value < 1.0/3.0:
            bg, fg = 'RED', 'WHITE'
        elif self.value > 2.0/3.0:
            bg, fg = 'LIGHTGREEN', 'BLACK'
        else:
            bg, fg = 'PALEGOLDENROD', 'BLACK'
        return bg, fg

class VibRoadmapsGrid(gridlib.Grid):
    """Simple grid for vibratory roadmaps PDFs accounting."""
    
    def __init__(self, parent, log, dayrow_labels, sensorcolumn_labels, rows):
        gridlib.Grid.__init__(self, parent, -1)
        self.log = log
        self.moveTo = None
        self.Bind(wx.EVT_IDLE, self.OnIdle)
        self.CreateGrid(len(dayrow_labels), len(sensorcolumn_labels))
        self.EnableEditing(False)

        self.SetDefaultRowSize(20)

        # set row labels with days
        for idx, day in enumerate(dayrow_labels):
            self.SetRowLabelValue(idx, day)
        self.SetRowLabelSize(99)            

        # set column labels as sensors
        for idx, sensor in enumerate(sensorcolumn_labels):
            self.SetColLabelValue(idx, sensor)
        self.SetColLabelSize(22)            

        # loop over rows
        r = 0
        for row in rows:
            c = 0
            for val in row:
                self.SetCellValue(r, c, str(val))
                self.SetCellAlignment(r, c, wx.ALIGN_CENTER, wx.ALIGN_CENTER)
                self.SetCellTextColour(r, c, wx.BLUE)
                c += 1
            r += 1

        # loop over rows
        for r in range(len(rows)):
            for c in range(len(rows[r])):
                self.SetCellValue(r, c, str(rows[r][c]))
                self.SetCellAlignment(r, c, wx.ALIGN_CENTER, wx.ALIGN_CENTER)
                self.SetCellTextColour(r, c, wx.BLUE)

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
        self.timer.Start(SB_MSEC)
        self.notify() # - call it once right away

    def get_time_str(self):
        return datetime.datetime.now().strftime('%d-%b-%Y,%j/%H:%M:%S ')

    def notify(self):
        """Timer event."""
        t = self.get_time_str() + ' (update every ' + str(int(SB_MSEC/1000.0)) + 's)'
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

class TestFrame(wx.Frame):
    def __init__(self, parent, log):
        wx.Frame.__init__(self, parent, -1, "VibratoryRoadmapsGrid", size=(1280, 1000))
        dayrow_labels = ['2013-10-31', '2013-11-01']
        sensorcolumn_labels = ['hirap','121f03','121f05onex']
        rows = [ [0.0, 0.5, 1.0], [0.9, 0.4, 0.2] ]
        self.grid = VibRoadmapsGrid(self, log, dayrow_labels, sensorcolumn_labels, rows)

if __name__ == '__main__':
    import sys
    app = wx.PySimpleApp()
    frame = TestFrame(None, sys.stdout)
    frame.Show(True)
    app.MainLoop()
