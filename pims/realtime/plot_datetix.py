#!/usr/bin/env python
version = '$Id$'

# This demo demonstrates how to draw a dynamic mpl (matplotlib) 
# plot in a wxPython application.
#
# It allows "live" plotting as well as manual zooming to specific
# regions.
#
# Both X and Y axes allow "auto" or "manual" settings. For Y, auto
# mode sets the scaling of the graph to see all the data points.
# For X, auto mode makes the graph "follow" the data. Set it X min
# to manual 0 to always see the whole data from the beginning.
#
# Note: press Enter in the 'manual' text box to make a new value 
# affect the plot.
#
# Adapted from code by:
# Eli Bendersky (eliben@gmail.com)
# License: this code is in the public domain
# Last modified: 31.07.2008

# FIXME make "step minutes" default (auto) value consistent (not five here, two there, etc.)

import os
import pprint
import random
import sys
import wx
import datetime

# The recommended way to use wx with mpl is with the WXAgg
# backend. 
#
import matplotlib
matplotlib.use('WXAgg')
from matplotlib.figure import Figure
from matplotlib.backends.backend_wxagg import \
    FigureCanvasWxAgg as FigCanvas, \
    NavigationToolbar2WxAgg as NavigationToolbar
import numpy as np
import pylab
#import matplotlib.dates as dates
import matplotlib.dates

from accelPacket import guessPacket, localtime, time, strftime
from collections import deque
MAXLEN = 5000 # for 2 deque's (time and data)

# Status bar and other constants
SB_LEFT = 0
SB_RIGHT = 1
SNAPSHOT_SEC = 30          # 30 seconds seems okay for snapshot updates without slowing down too much
EVT_RESULT_ID = wx.NewId() # Define notification event for thread completion

def EVT_RESULT(win, func):
    """Define Result Event."""
    win.Connect(-1, -1, EVT_RESULT_ID, func)

class SillyDataGen(object):
    """ A silly class that generates pseudo-random data for
        display in the plot.
    """
    def __init__(self, init=50):
        self.time = datetime.datetime(2012, 12, 31, 23, 58, 00) - datetime.timedelta(seconds=30)
        self.data = self.init = init
        
    def next(self):
        self._recalc_data()
        return self.time, self.data
    
    def _recalc_data(self):
        delta = random.uniform(-0.5, 0.5)
        r = random.random()

        if r > 0.9:
            self.data += delta * 15
        elif r > 0.8: 
            # attraction to the initial value
            delta += (0.5 if self.init > self.data else -0.5)
            self.data += delta
        else:
            self.data += delta
        
        self.time += datetime.timedelta(seconds=10)

class BoundControlBox(wx.Panel):
    """ A static box with a couple of radio buttons and a text
        box. Allows to switch between an automatic mode and a 
        manual mode with an associated value.
    """
    def __init__(self, parent, ID, label, initval):
        wx.Panel.__init__(self, parent, ID)
        
        self.value = initval
        
        box = wx.StaticBox(self, -1, label)
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)
        
        self.radio_auto = wx.RadioButton(self, -1, label="Auto", style=wx.RB_GROUP)
        self.radio_auto.SetValue( True )
        self.radio_manual = wx.RadioButton(self, -1, label="Manual")
        self.manual_text = wx.TextCtrl(self, -1, size=(50,-1), value=str(initval), style=wx.TE_PROCESS_ENTER)
        
        self.Bind(wx.EVT_UPDATE_UI, self.on_update_manual_text, self.manual_text)
        self.Bind(wx.EVT_TEXT_ENTER, self.on_text_enter, self.manual_text)
        
        manual_box = wx.BoxSizer(wx.HORIZONTAL)
        manual_box.Add(self.radio_manual, flag=wx.ALIGN_CENTER_VERTICAL)
        manual_box.Add(self.manual_text, flag=wx.ALIGN_CENTER_VERTICAL)
        
        sizer.Add(self.radio_auto, 0, wx.ALL, 10)
        sizer.Add(manual_box, 0, wx.ALL, 10)
        
        self.SetSizer(sizer)
        sizer.Fit(self)
    
    def on_update_manual_text(self, event):
        self.manual_text.Enable(self.radio_manual.GetValue())
    
    def on_text_enter(self, event):
        self.value = self.manual_text.GetValue()
    
    def is_auto(self):
        return self.radio_auto.GetValue()
        
    def manual_value(self):
        return self.value

class GraphFrame(wx.Frame):
    """ The main frame of the application
    """
    title = 'dynamic matplotlib graph'
    
    def __init__(self):
        wx.Frame.__init__(self, None, -1, self.title)
        self.Maximize()
        
        self.time = deque( maxlen=MAXLEN )
        self.data = deque( maxlen=MAXLEN )
        self.time.append( datetime.datetime.now() )
        self.data.append( pylab.NaN )

        self.paused = False
        
        self.create_menu()
        self.create_status_bar()
        self.create_main_panel()
        
        # Set up event handler for any worker thread results
        EVT_RESULT(self,self.onResult)

        # And indicate we don't have a worker thread yet
        self.worker = None

        # Set up a timer to update the date/time after snapshot
        self.timer = wx.PyTimer(self.notify)
        self.timer.Start(SNAPSHOT_SEC*1000.0)
        
        #self.redraw_timer = wx.Timer(self)
        #self.Bind(wx.EVT_TIMER, self.on_redraw_timer, self.redraw_timer)        
        #self.redraw_timer.Start(1000)

    def create_menu(self):
        self.menubar = wx.MenuBar()
        
        menu_file = wx.Menu()
        m_expt = menu_file.Append(-1, "&Save plot\tCtrl-S", "Save plot to file")
        self.Bind(wx.EVT_MENU, self.on_save_plot, m_expt)
        menu_file.AppendSeparator()
        m_exit = menu_file.Append(-1, "E&xit\tCtrl-X", "Exit")
        self.Bind(wx.EVT_MENU, self.on_exit, m_exit)
                
        self.menubar.Append(menu_file, "&File")
        self.SetMenuBar(self.menubar)

    def create_main_panel(self):
        self.panel = wx.Panel(self)

        self.init_plot()
        self.canvas = FigCanvas(self.panel, -1, self.fig)

        self.ymin_control = BoundControlBox(self.panel, -1, "Y min", 0)
        self.ymax_control = BoundControlBox(self.panel, -1, "Y max", 2000)
        self.ymin_control.radio_auto.SetValue( False )
        self.ymax_control.radio_auto.SetValue( False )
        self.ymin_control.radio_manual.SetValue( True )
        self.ymax_control.radio_manual.SetValue( True )        
        self.byminute_step_control = BoundControlBox(self.panel, -1, "Step Minutes", 5)
        
        self.show_button = wx.Button(self.panel, -1, "Show")
        self.hide_button = wx.Button(self.panel, -1, "Hide")
        self.pause_button = wx.Button(self.panel, -1, "Pause")
        self.Bind(wx.EVT_BUTTON, self.on_show_button, self.show_button)
        self.Bind(wx.EVT_BUTTON, self.on_hide_button, self.hide_button)
        self.Bind(wx.EVT_BUTTON, self.on_pause_button, self.pause_button)
        self.Bind(wx.EVT_UPDATE_UI, self.on_update_pause_button, self.pause_button)
        
        self.cb_grid = wx.CheckBox(self.panel, -1, "Show Grid", style=wx.ALIGN_RIGHT)
        self.Bind(wx.EVT_CHECKBOX, self.on_cb_grid, self.cb_grid)
        self.cb_grid.SetValue(True)
        
        self.cb_xlab = wx.CheckBox(self.panel, -1, "Show X labels", style=wx.ALIGN_RIGHT)
        self.Bind(wx.EVT_CHECKBOX, self.on_cb_xlab, self.cb_xlab)        
        self.cb_xlab.SetValue(True)
        
        self.hbox1 = wx.BoxSizer(wx.HORIZONTAL)
        self.hbox1.Add(self.show_button, border=5, flag=wx.ALL | wx.ALIGN_CENTER_VERTICAL)
        self.hbox1.AddSpacer(10)
        self.hbox1.Add(self.hide_button, border=5, flag=wx.ALL | wx.ALIGN_CENTER_VERTICAL)
        self.hbox1.AddSpacer(10)
        self.hbox1.Add(self.pause_button, border=5, flag=wx.ALL | wx.ALIGN_CENTER_VERTICAL)
        self.hbox1.AddSpacer(10)        
        self.hbox1.Add(self.cb_grid, border=5, flag=wx.ALL | wx.ALIGN_CENTER_VERTICAL)
        self.hbox1.AddSpacer(10)
        self.hbox1.Add(self.cb_xlab, border=5, flag=wx.ALL | wx.ALIGN_CENTER_VERTICAL)
        
        self.hbox2 = wx.BoxSizer(wx.HORIZONTAL)
        self.hbox2.AddSpacer(24)        
        self.hbox2.Add(self.ymin_control, border=5, flag=wx.ALL)
        self.hbox2.Add(self.ymax_control, border=5, flag=wx.ALL)
        self.hbox2.AddSpacer(24)
        self.hbox2.Add(self.byminute_step_control, border=5, flag=wx.ALL)

        self.vbox = wx.BoxSizer(wx.VERTICAL)
        self.vbox.Add(self.canvas, 1, flag=wx.LEFT | wx.TOP | wx.GROW)        
        self.vbox.Add(self.hbox1, 0, flag=wx.ALIGN_LEFT | wx.TOP)
        self.vbox.Add(self.hbox2, 0, flag=wx.ALIGN_LEFT | wx.TOP)
        
        self.panel.SetSizer(self.vbox)
        self.vbox.Fit(self)

    def onResult(self, event):
        """Show Result status."""
        if event.data is None:
            # Thread aborted (using our convention of None return)
            self.SetStatusText('Processing aborted.', SB_LEFT)
            self.text.WriteText('\nPROCESSING ABORTED AT %s' % datetime.datetime.now() )
        else:
            # Process results here
            self.SetStatusText( '%s %s' % event.data, SB_LEFT)
        # In either event, the worker is done
        self.worker = None

    def getTimeString(self):
        t = localtime(time())
        return strftime('%d-%b-%Y,%j/%H:%M:%S ', t)

    def notify(self):
        """ Timer event """
        self.canvas.print_figure('/misc/yoda/www/plots/sams/121f05/test.png', dpi=self.dpi)
        t = 'Last snap: ' + self.getTimeString() + ' (every ' + str(int(SNAPSHOT_SEC)) + 's)'
        self.SetStatusText(t, SB_RIGHT)
    
    def create_status_bar(self):
        self.statusbar = self.CreateStatusBar(2, 0)        
        self.statusbar.SetStatusWidths([-1, 350])
        self.statusbar.SetStatusText('Ready', SB_LEFT)        

    def update_AOS(self, txt):
        self.lower_left_aos.set_text( txt.split(',')[1] )
        if txt.endswith('AOS'):
            self.lower_left_aos.set_color('DarkGreen')
        else:
            self.lower_left_aos.set_color('Red')

    def init_plot(self):
        self.dpi = 120
        self.fig = Figure((6.0, 6.0), dpi=self.dpi)

        self.axes = self.fig.add_subplot(111)
        self.axes.set_axis_bgcolor('white')
        self.axes.set_title('testing with random data', size=12)
        self.upper_right_time = self.axes.annotate( 'upper_right_text', xy=(1.00, 1.09), xycoords='axes fraction', horizontalalignment='center', verticalalignment='top', fontsize=9, color='gray')
        self.lower_left_aos = self.axes.annotate( 'lower_left_aos', xy=(-0.14, -0.11), xycoords='axes fraction', horizontalalignment='left', verticalalignment='bottom', fontsize=9, color='blue')
        
        pylab.setp(self.axes.get_xticklabels(), fontsize=10)
        pylab.setp(self.axes.get_yticklabels(), fontsize=10)

        self.axes.set_ylabel('Interval Average Acceleration Vector Magnitude (ug)', fontsize=10)

        self.axes.tick_params(labelright=True, labelsize=10)

        self.axes.xaxis.set_major_locator( matplotlib.dates.MinuteLocator( byminute=range(0,60,5) ) )
        self.axes.xaxis.set_major_formatter( matplotlib.dates.DateFormatter('%H:%M:%S\n%d-%b-%Y') )

        # plot the data as a line series, and save reference to plotted line series
        self.plot_data = self.axes.plot_date( self.time, self.data, 'k.-')[0]

    def draw_plot(self):
        """ Redraws the plot
        """
        # when xmin is on auto, it "follows" xmax to produce a 
        # sliding window effect. therefore, xmin is assigned after
        # xmax.
        #
        #if self.xmax_control.is_auto():
        #    xmax = len(self.data) if len(self.data) > 50 else 50
        #else:
        #    xmax = int(self.xmax_control.manual_value())
        #
        #if self.xmin_control.is_auto():            
        #    xmin = xmax - 50
        #else:
        #    xmin = int(self.xmin_control.manual_value())

        xmax = max(self.time)
        xmin = xmax - datetime.timedelta(hours=0.5)

        if self.byminute_step_control.is_auto():
            bymin_step = 5
        else:
            bymin_step = int( self.byminute_step_control.manual_value() )
            
        # for ymin and ymax, find the minimal and maximal values
        # in the data set and add a mininal margin.
        # 
        # note that it's easy to change this scheme to the 
        # minimal/maximal value in the current display, and not
        # the whole data set.
        # 
        if self.ymin_control.is_auto():
            ymin = round(min(self.data), 0) - 1
        else:
            ymin = int(self.ymin_control.manual_value())
        
        if self.ymax_control.is_auto():
            ymax = round(max(self.data), 0) + 1
        else:
            ymax = int(self.ymax_control.manual_value())

        self.axes.set_xbound(lower=xmin, upper=xmax)
        self.axes.set_ybound(lower=ymin, upper=ymax)
        self.axes.xaxis.set_major_locator( matplotlib.dates.MinuteLocator( byminute=range(0, 60, bymin_step) ) )
        
        # anecdote: axes.grid assumes b=True if any other flag is
        # given even if b is set to False.
        # so just passing the flag into the first statement won't
        # work.
        #
        if self.cb_grid.IsChecked():
            self.axes.grid(True, color='gray')
        else:
            self.axes.grid(False)

        # Using setp here is convenient, because get_xticklabels
        # returns a list over which one needs to explicitly 
        # iterate, and setp already handles this.
        #  
        pylab.setp(self.axes.get_xticklabels(), visible=self.cb_xlab.IsChecked())
        
        #self.plot_data.set_xdata(np.arange(len(self.data)))
        self.plot_data.set_xdata(np.array(self.time))
        self.plot_data.set_ydata(np.array(self.data))
        
        self.canvas.draw()

    def on_show_button(self, event):
        """show notify window"""
        self.flash_status_message('show the notify window')

    def on_hide_button(self, event):
        self.flash_status_message('hide the notify window')
    
    def on_pause_button(self, event):
        self.paused = not self.paused
    
    def on_update_pause_button(self, event):
        label = "Resume" if self.paused else "Pause"
        self.pause_button.SetLabel(label)
    
    def on_cb_grid(self, event):
        self.draw_plot()
    
    def on_cb_xlab(self, event):
        self.draw_plot()
    
    def on_save_plot(self, event):
        file_choices = "PNG (*.png)|*.png"
        
        dlg = wx.FileDialog(
            self, 
            message="Save plot as...",
            defaultDir=os.getcwd(),
            defaultFile="plot.png",
            wildcard=file_choices,
            style=wx.SAVE)
        
        if dlg.ShowModal() == wx.ID_OK:
            path = dlg.GetPath()
            self.canvas.print_figure(path, dpi=self.dpi)
            self.flash_status_message("Saved to %s" % path)

    def update_plot(self, t, d):
        # if paused do not add data, but still redraw the plot (to respond to
        # scale modifications, grid change, etc.)
        if not self.paused:
            self.time.append( t )
            self.data.append( d )
            self.upper_right_time.set_text( self.time[-1].strftime('%d-%b-%Y\n%H:%M:%S') )
        
        self.draw_plot()
    
    def on_exit(self, event):
        self.Destroy()
    
    def flash_status_message(self, msg, flash_len_ms=1500):
        self.statusbar.SetStatusText(msg, SB_LEFT)
        self.timeroff = wx.Timer(self)
        self.Bind(
            wx.EVT_TIMER, 
            self.on_flash_status_off, 
            self.timeroff)
        self.timeroff.Start(flash_len_ms, oneShot=True)
    
    def on_flash_status_off(self, event):
        self.statusbar.SetStatusText('')
