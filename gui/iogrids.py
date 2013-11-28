#!/usr/bin/env python

import sys
import wx
import wx.grid as gridlib
from wx.lib.pubsub import Publisher
import datetime

class InputPanel(wx.Panel):
    """The input panel."""
    
    def __init__(self, parent, log, input_grid, grid_worker):
        """Constructor"""
        wx.Panel.__init__(self, parent=parent)
        self.parent = parent

        self.grid = input_grid(self, log)
        self.grid.CreateGrid( len(self.grid.row_labels), len(self.grid.column_labels) )
        
        self.grid.set_row_labels()
        self.grid.set_column_labels()
        self.grid.set_default_cell_values()  
        
        self.grid_worker = grid_worker
        
        self.main_sizer = wx.BoxSizer(wx.VERTICAL)
        self.btn_sizer = wx.BoxSizer(wx.HORIZONTAL)
        
        switch_btn = wx.Button(self, label="Switch")
        switch_btn.Bind(wx.EVT_BUTTON, self.switchback)
        
        run_btn = wx.Button(self, label="Run")
        run_btn.Bind(wx.EVT_BUTTON, self.on_run)
        
        self.btn_sizer.Add(switch_btn, 0, wx.ALL|wx.LEFT, 5)
        self.btn_sizer.Add(run_btn, 0, wx.ALL|wx.LEFT, 4)
        self.main_sizer.Add(self.btn_sizer)
        self.main_sizer.Add(self.grid, 0, wx.EXPAND)
        self.SetSizer(self.main_sizer)
        
    def switchback(self, event):
        """Callback for panel switch button."""
        Publisher.sendMessage("switch", "message")

    def on_run(self, event):
        """Callback for run button."""
        
        # get inputs from input grid
        inputs = self.grid.get_inputs()
        
        # instantiate grid_worker with inputs
        gw = self.grid_worker(inputs)
        gw.get_results() # gets row_labels, column_labels, and rows
        
        # add more to inputs, which makes our outputs
        inputs['row_labels'] = gw.row_labels
        inputs['column_labels'] = gw.column_labels
        inputs['rows'] = gw.rows
        
        # out with the old results grid
        self.parent.output_panel.remove_grid()
        
        # in with the new results grid
        self.parent.output_panel.add_grid(results=inputs)
        
        #for k,v in inputs.iteritems():
        #    print '-' * 11
        #    print k
        #    print v
            
        # now we can fill the output grid
        #self.parent.output_panel.grid.early_method(inputs)

class OutputPanel(wx.Panel):
    """The output panel."""
 
    def __init__(self, parent, log, output_grid):
        """Constructor"""
        wx.Panel.__init__(self, parent)
        self.parent = parent
        self.log = log        
        self.output_grid = output_grid
        
        self.number_of_grids = 0
        self.frame = parent
 
        self.main_sizer = wx.BoxSizer(wx.VERTICAL)
        control_sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.widget_sizer = wx.BoxSizer(wx.VERTICAL)
 
        self.switch_btn = wx.Button(self, label="Switch")
        self.switch_btn.Bind(wx.EVT_BUTTON, self.switchback)
        control_sizer.Add(self.switch_btn, 0, wx.LEFT|wx.ALL, 5)
 
        self.update_btn = wx.Button(self, label="Update")
        self.update_btn.Bind(wx.EVT_BUTTON, self.on_update)
        control_sizer.Add(self.update_btn, 0, wx.LEFT|wx.ALL, 5)
 
        self.main_sizer.Add(control_sizer, 0, wx.LEFT)
        self.main_sizer.Add(self.widget_sizer, 0, wx.LEFT|wx.ALL, 10)
 
        self.SetSizer(self.main_sizer)
 
    def switchback(self, event):
        """Callback for panel switch button."""
        Publisher.sendMessage("switch", "message")
 
    def add_grid(self, results=None):
        """Add grid."""
        if results:
            nrows = len(results['row_labels'])
            ncols = len(results['column_labels'])
            new_grid = gridlib.Grid(self, -1)
            new_grid.CreateGrid(nrows, ncols)
            new_grid.SetCellValue(0, 0, 'this is where results would go')
        else:
            new_grid = gridlib.Grid(self, -1)
            new_grid.CreateGrid(3, 3)
            new_grid.SetCellValue(0, 0, 'no results yet')
        self.widget_sizer.Add(new_grid, 0, wx.ALL, 5)
        self.frame.sizer.Layout()
        self.frame.Fit()        
 
    def remove_grid(self):
        """Remove grid."""
        if self.widget_sizer.GetChildren():
           self.widget_sizer.Hide(0)
           self.widget_sizer.Remove(0)
           self.frame.sizer.Layout()
           self.frame.Fit()
 
    def on_update(self, event):
        """Remove output grid."""
        print 'output panel update not implemented yet'

class MainFrame(wx.Frame):
    """The parent frame for the i/o panels."""
    
    # Status bar constants
    SB_LEFT = 0
    SB_RIGHT = 1
    
    def __init__(self, log, input_grid, grid_worker, output_grid):
        wx.Frame.__init__(self, None, wx.ID_ANY, 'Main Frame Title')
 
        self.SetPosition( (1850, 22) )
        self.SetSize( (1533, 955) )
 
        self.grid_worker = grid_worker
 
        self.input_panel = InputPanel(self, log, input_grid, grid_worker)
        self.output_panel = OutputPanel(self, log, output_grid)
        self.output_panel.Hide()
        
        self.sizer = wx.BoxSizer(wx.VERTICAL)
        self.sizer.Add(self.input_panel, 1, wx.EXPAND)
        self.sizer.Add(self.output_panel, 1, wx.EXPAND)
        self.SetSizer(self.sizer)

        self.output_panel.add_grid()
        
        Publisher().subscribe(self.switch_panels, "switch")
        
        # menu bar
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
        
        # Status bar
        self.statusbar = self.CreateStatusBar(2, 0)        
        self.statusbar.SetStatusWidths([-1, 320])
        self.statusbar.SetStatusText("Ready", self.SB_LEFT)
        
        # Set up a timer to update the date/time (every few seconds)
        self.update_sec = 5
        self.timer = wx.PyTimer(self.notify)
        self.timer.Start( int(self.update_sec * 1000) )
        self.notify() # call it once right away
        
        self.Maximize(True)
        
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
            
        #self.Fit()
        self.Layout()

    def get_time_str(self):
        return datetime.datetime.now().strftime('%d-%b-%Y,%j/%H:%M:%S ')

    def notify(self):
        """Timer event updated every so often."""
        #self.update_grid()
        t = self.get_time_str() + ' (update every ' + str(int(self.update_sec)) + 's)'
        self.statusbar.SetStatusText(t, self.SB_RIGHT)
    
if __name__ == "__main__":
    from pims.utils.pad_hours_grid import demo
    demo()
