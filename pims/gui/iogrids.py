#!/usr/bin/env python

import wx
import wx.grid as gridlib
from wx.lib.pubsub import Publisher

class BasePanel(wx.Panel):
    """Base panel."""
    
    def __init__(self, parent, pims_grid):
        """Constructor"""
        wx.Panel.__init__(self, parent=parent)
        
        grid = gridlib.Grid(self)
        grid.CreateGrid(5,4)
        btn = wx.Button(self, label="Switch")
        btn.Bind(wx.EVT_BUTTON, self.switchback)
        
        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(grid, 0, wx.EXPAND)
        sizer.Add(btn, 0, wx.ALL|wx.LEFT, 5)
        self.SetSizer(sizer)

    def switchback(self, event):
        """Send message for switching."""
        Publisher.sendMessage("switch", "message")

class PimsGrid(gridlib.Grid):
    
    def init_row_labels(self, row_labels):
        self.row_labels = row_labels
        self.nrows = len(row_labels)

    def init_column_labels(self, column_labels):
        self.column_labels = column_labels
        self.ncols = len(column_labels)

class InputPanel(wx.Panel):
    """The input panel."""
    
    def __init__(self, parent, pims_grid=PimsGrid):
        """Constructor"""
        wx.Panel.__init__(self, parent=parent)
        
        self.grid = pims_grid(self)
        
        self.grid.init_row_labels( ['row1','row2'] )
        self.grid.init_column_labels( ['c1','c2','c3'] )
        
        self.grid.CreateGrid( self.grid.nrows, self.grid.ncols )
        
        self.set_grid_row_labels()
        self.set_grid_column_labels()
        
        btn = wx.Button(self, label="Switch")
        btn.Bind(wx.EVT_BUTTON, self.switchback)
        
        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(self.grid, 0, wx.EXPAND)
        sizer.Add(btn, 0, wx.ALL|wx.LEFT, 5)
        self.SetSizer(sizer)

    def set_grid_row_labels(self):
        """Set the row labels for this panel's grid."""
        for i,v in enumerate(self.grid.row_labels):
            self.grid.SetRowLabelValue(i, v) 

    def set_grid_column_labels(self):
        """Set the column labels for this panel's grid."""
        for i,v in enumerate(self.grid.column_labels):
            self.grid.SetColLabelValue(i, v)       

    def switchback(self, event):
        """"""
        Publisher.sendMessage("switch", "message")

class OutputPanel(wx.Panel):
    """The output panel."""

    def __init__(self, parent):
        """Constructor"""
        wx.Panel.__init__(self, parent=parent)
        
        grid = gridlib.Grid(self)
        grid.CreateGrid(25,12)
        btn = wx.Button(self, label="Switch")
        btn.Bind(wx.EVT_BUTTON, self.switchback)
        
        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(grid, 0, wx.EXPAND)
        sizer.Add(btn, 0, wx.ALL|wx.LEFT, 5)
        self.SetSizer(sizer)
        
    def switchback(self, event):
        """"""
        Publisher.sendMessage("switch", "message")
        
        
class MainFrame(wx.Frame):
    """The parent frame for the i/o panels."""
    
    def __init__(self):
        wx.Frame.__init__(self, None, wx.ID_ANY, "Panel Switcher Tutorial")
 
        self.input_panel = InputPanel(self)
        self.output_panel = OutputPanel(self)
        self.output_panel.Hide()
        
        self.sizer = wx.BoxSizer(wx.VERTICAL)
        self.sizer.Add(self.input_panel, 1, wx.EXPAND)
        self.sizer.Add(self.output_panel, 1, wx.EXPAND)
        self.SetSizer(self.sizer)
        
        Publisher().subscribe(self.switch_panels, "switch")
        
        menubar = wx.MenuBar()
        panelMenu = wx.Menu()
        self.panelMenu = panelMenu
        switch_panels_menu_item = panelMenu.Append(wx.ID_ANY, 
                                                  "Switch Panels", 
                                                  "Some text")
        self.Bind(wx.EVT_MENU, self.on_switch_panels, 
                  switch_panels_menu_item)
        
        menubar.Append(panelMenu, '&Panel')
        self.SetMenuBar(menubar)
        
    def on_switch_panels(self, event):
        """"""
        id = event.GetId()
        self.switch_panels(id)
        
    def switch_panels(self, msg=None):
        """"""
        item = self.panelMenu.FindItemById(self.panelMenu.FindItem("Switch Panels"))
        if item:
            item.SetItemLabel("Go Input Panel")
        
        if self.input_panel.IsShown():
            self.SetTitle("Output Panel")
            self.input_panel.Hide()
            self.output_panel.Show()
            self.sizer.Layout()
            
            try:
                item = self.panelMenu.FindItemById(self.panelMenu.FindItem("Go Output Panel"))
                item.SetItemLabel("Go Input Panel")
            except:
                pass
            
        else:
            self.SetTitle("Input Panel")
            self.input_panel.Show()
            self.output_panel.Hide()
            
            item = self.panelMenu.FindItemById(self.panelMenu.FindItem("Go Input Panel"))
            item.SetItemLabel("Go Output Panel")
            
        self.Fit()
        
if __name__ == "__main__":
    app = wx.App(False)
    frame = MainFrame()
    frame.Show()
    app.MainLoop()
