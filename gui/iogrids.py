#!/usr/bin/env python

import sys
import wx
import wx.grid as gridlib
from wx.lib.pubsub import Publisher

class InputPanel(wx.Panel):
    """The input panel."""
    
    def __init__(self, parent, log, input_grid):
        """Constructor"""
        wx.Panel.__init__(self, parent=parent)
        
        self.grid = input_grid(self, log)
        self.grid.CreateGrid( len(self.grid.row_labels), len(self.grid.column_labels) )
        
        self.grid.set_row_labels()
        self.grid.set_column_labels()
        self.grid.set_default_cell_values()  
        
        btn = wx.Button(self, label="Switch")
        btn.Bind(wx.EVT_BUTTON, self.switchback)
        
        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(self.grid, 0, wx.EXPAND)
        sizer.Add(btn, 0, wx.ALL|wx.LEFT, 5)
        self.SetSizer(sizer)

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
    
    def __init__(self, log, title, input_grid, grid_worker):
        wx.Frame.__init__(self, None, wx.ID_ANY, title)
 
        self.SetPosition( (1850, 22) )
        self.SetSize( (1533, 955) )
 
        self.grid_worker = grid_worker
 
        self.input_panel = InputPanel(self, log, input_grid)
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
        
        self.input_panel.grid.get_inputs()
        print '- ' * 22
        for i, v in enumerate(self.input_panel.grid.rows):
            print 'row %02d: %s = %s' %( i, v[0], v[1])
    
if __name__ == "__main__":
    demo()
