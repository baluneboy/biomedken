#!/usr/bin/env python

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
# Most of the strip chart aspects of this are thanks to Eli, that is:
# Eli Bendersky (eliben@gmail.com)
# License: this code is in the public domain
# Last modified: 31.07.2008 (by Eli)

import os
import logging
import random
import sys
import wx
import numpy as np
from collections import deque
import datetime
from wx.lib.pubsub import Publisher

# The recommended way to use wx with mpl is with the WXAgg
# backend.
import pylab
import matplotlib
from matplotlib import dates
#matplotlib.use('WXAgg') # this throws a warning!?
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
from matplotlib.backends.backend_wxagg import \
      FigureCanvasWxAgg as FigCanvas, \
      NavigationToolbar2WxAgg as NavigationToolbar
#from matplotlib.ticker import AutoMinorLocator

#from pims.realtime import rt_params as RTPARAMS
from pims.gui.iogrids import StripChartInputPanel
from pims.gui.tally_grid import StripChartInputGrid
from pims.files.log import SimpleLog
from pims.utils.benchmark import Benchmark
from pims.utils.pimsdateutil import unix2dtm

from obspy.core.utcdatetime import UTCDateTime
from obspy.realtime import RtTrace
from obspy import read

# Status bar and other global vars
SB_LEFT = 0
SB_RIGHT = 1
REDRAW_MSEC = 5000 # redraw timer every 5 to 10 seconds or so
SB_MSEC = int( 2 * REDRAW_MSEC ) #  lower-right time ~every several seconds
BENCH_STEP = Benchmark('step') # datagen next method ("step") should avg about 3s

# PIMS-friendly extension of RtTrace
class PimsRtTrace(RtTrace):
    """PIMS-friendly extension of RtTrace"""
    
    def absolute_times(self):
        """absolute unixtime"""
        return self.times() + float(self.stats.starttime)
    
    def slice_after(self, min_time):
        t = self.absolute_times()
        idx = np.where(t >= min_time)
        dtm = [unix2dtm(i) for i in t[idx]]
        return dates.date2num( dtm ), self[idx]
    
class DataGenRandom(object):
    """ A silly class that generates pseudo-random data for plot display."""
    def __init__(self, init=50):
        self.data = self.init = init
        
    def next(self):
        self._recalc_data()
        return self.data
    
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

class DataGenExample(object):
    """Generator for RtTrace using trace split and rt scaling on example slist ascii file."""
    
    def __init__(self, scale_factor=0.1, num_splits=3):
        self.num = -1
        
        self.scale_factor = scale_factor
        self.num_splits = num_splits
        
        # read example trace (with demean stream first)
        self.data_trace = self.read_example_trace_demean()
        
        # split given trace into a list of three sub-traces:
        self.traces = self.split_trace()
        
        # assemble real time trace and register rt proc (scale by factor)
        self.rt_trace, i1 = self.assemble_rttrace_register1proc()
    
        # append and auto-process packet data into RtTrace:
        self.append_and_autoprocess_packet()
        self.header_string = 'example header string'
    
    def next(self, step_callback=None):
        if self.num < len(self.rt_trace) - 1:
            self.num += 1
            if step_callback:
                current_info_tuple = ('0000-00-00 00:00:00.000', '0000-00-00 00:00:00.000', '%6d' % self.num)
                cumulative_info_tuple = ('%6d' % len(self.rt_trace), '0000-00-00 00:00:00.000', '0000-00-00 00:00:00.000')
                step_callback(current_info_tuple, cumulative_info_tuple)
            return self.rt_trace[self.num]
        else:
            #raise StopIteration()
            self.num = -1
            return 0
    
    def read_example_trace_demean(self):
        """Read first trace of example data file"""
        st = read('/home/pims/dev/programs/python/pims/sandbox/data/slist_for_example.ascii')
        st.detrend('demean')
        data_trace = st[0]
        return data_trace

    def split_trace(self):
        """split given trace into a list of three sub-traces"""
        traces = self.data_trace / self.num_splits
        return traces

    def assemble_rttrace_register1proc(self):
        """assemble real time trace and register one process"""
        #rt_trace = RtTrace()
        rt_trace = PimsRtTrace()
        return rt_trace, rt_trace.registerRtProcess('scale', factor=self.scale_factor)

    def append_and_autoprocess_packet(self):
        """append and auto-process packet data into RtTrace"""
        for tr in self.traces:
            self.rt_trace.append(tr, gap_overlap_check=True)

class DataGenBetterExample(object):
    """Generator for X,Y,Z RtTraces using trace split and rt scaling on example slist ascii file."""
    
    def __init__(self, scale_factor=0.1, num_splits=3):
        self.num = -1
        
        self.scale_factor = scale_factor
        self.num_splits = num_splits
        
        # read example trace (with demean stream first)
        self.data_trace = self.read_example_trace_demean()
        
        # split given trace into a list of sub-traces:
        self.traces = self.split_trace()
        
        # assemble real time traces and register rt proc (scale by factor)
        self.rt_trace = {}
        for ax in ['x', 'y', 'z']:
            self.rt_trace[ax], i1 = self.assemble_rttrace_register1proc()
    
        # append and auto-process packet data into RtTrace:
        self.append_and_autoprocess_packet()
        self.header_string = 'example header string'

    def next(self, step_callback=None):
        if self.num < len(self.rt_trace) - 1:
            self.num += 1
            self.rt_trace['y'].filter('lowpass', freq=2.0, zerophase=True)
            self.rt_trace['z'].filter('highpass', freq=2.0, zerophase=True)
            min_time = self.rt_trace['x'].absolute_times()[self.num]
            t, x = self.rt_trace['x'].slice_after(min_time)
            y = self.rt_trace['y'].slice_after(min_time)[1]
            z = self.rt_trace['z'].slice_after(min_time)[1]
            if step_callback:
                current_info_tuple = (str(UTCDateTime(t[0])), str(UTCDateTime(t[-1])), '%d' % len(x))
                cumulative_info_tuple = ('%d' % len(self.rt_trace), str(UTCDateTime(t[-1])), str(UTCDateTime(t[-1])))
                step_callback(current_info_tuple, cumulative_info_tuple)
            return t, x
        else:
            #raise StopIteration()
            self.num = -1
            return [], []
    
    def read_example_trace_demean(self):
        """Read first trace of example data file"""
        st = read('/home/pims/dev/programs/python/pims/sandbox/data/slist_for_example.ascii')
        st.detrend('demean')
        data_trace = st[0]
        return data_trace

    def split_trace(self):
        """split given trace into a list of three sub-traces"""
        traces = self.data_trace / self.num_splits
        return traces

    def assemble_rttrace_register1proc(self):
        """assemble real time trace and register one process"""
        rt_trace = PimsRtTrace()
        return rt_trace, rt_trace.registerRtProcess('scale', factor=self.scale_factor)

    def append_and_autoprocess_packet(self):
        """append and auto-process packet data into RtTrace"""
        for ax in ['x', 'y', 'z']:
            for tr in self.traces:
                self.rt_trace[ax].append(tr, gap_overlap_check=True)

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
        
        self.radio_auto = wx.RadioButton(self, -1, 
            label="Auto", style=wx.RB_GROUP)
        self.radio_manual = wx.RadioButton(self, -1,
            label="Manual")
        self.manual_text = wx.TextCtrl(self, -1, 
            size=(50,-1),
            value=str(initval),
            style=wx.TE_PROCESS_ENTER)
        
        self.Bind(wx.EVT_UPDATE_UI, self.on_update_manual_text, self.manual_text)
        self.Bind(wx.EVT_TEXT_ENTER, self.on_text_enter, self.manual_text) # FIXME bind change (not just ENTER)?

        ## set manual values during initialize here
        #self.radio_manual.SetValue(True)
        
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

class BeginEndSamplesBox(wx.Panel):
    """ An info box with begin, end, and number of samples text."""
    def __init__(self, parent, ID, label):
        wx.Panel.__init__(self, parent, ID)
        
        box = wx.StaticBox(self, -1, label)
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.begin_time_text = wx.StaticText(self, -1, '0000-00-00 00:00:00.000')
        self.end_time_text = wx.StaticText(self, -1, '0000-00-00 00:00:00.000')
        self.samples_text = wx.StaticText(self, -1, '000000')
       
        sizer.Add(self.begin_time_text, 0, wx.ALL, 10)
        sizer.Add(self.end_time_text, 0, wx.ALL, 10)
        sizer.Add(self.samples_text, 0, wx.ALL, 10)
        
        self.SetSizer(sizer)
        #sizer.Fit(self)
    
    def on_update_manual_text(self, event):
        self.manual_text.Enable(self.radio_manual.GetValue())
    
    def on_text_enter(self, event):
        self.value = self.manual_text.GetValue()
    
    def is_auto(self):
        return self.radio_auto.GetValue()
        
    def manual_value(self):
        return self.value

class GraphFrame(wx.Frame):
    """ The main frame (window) of the strip chart application.
    
    datagen is data generator (let's use its next method)
    title string
    log to keep track of things
    
    """
    def __init__(self, datagen, title, log, rt_params):
        
        self.datagen = datagen
        self.title = '%s using %s' % (title, self.datagen.__class__.__name__)
        self.log = log
        self.rt_params = rt_params
        
        wx.Frame.__init__(self, None, -1, self.title)
        
        #self.create_menu() # on close, this causes LIBDBUSMENU-GLIB-WARNING Trying to remove a child that doesn't believe we're it's parent.
        
        self.create_status_bar()
        self.create_panels()

        ## get initial values for plot_span, analysis_interval, extra_intervals, maxlen, etc.
        #self.get_inputs()

        # we must limit size of otherwise ever-growing data object
        self.data = deque( maxlen=self.rt_params['data.maxlen'] )
        
        # this is first call to "prime the pump" of data generator via next method
        self.paused = False
        self.data.append( self.datagen.next(self.step_callback) )
        self.paused = True
       
        # after our first "next" call above, set plot title using datagen's header_string
        self.set_plot_title(self.datagen.header_string)
       
        # Set up a timer to update the date/time (every few seconds)
        self.timer = wx.PyTimer(self.notify)
        self.timer.Start(SB_MSEC)
        self.notify() # call it once right away
        
        # Set up redraw timer
        self.redraw_timer = wx.Timer(self)
        self.Bind(wx.EVT_TIMER, self.on_redraw_timer, self.redraw_timer)        
        self.redraw_timer.Start(REDRAW_MSEC) # milliseconds
        
        # Do initial redraw
        self.draw_plot()
        self.Maximize()
        
        self.log.debug('GraphFrame was initialized.')

    def get_inputs(self):
        """get values from input panel grid"""
        # get inputs in dict form from input grid
        inputs = self.input_panel.grid.get_inputs()
        
        # set attributes of this graph frame using inputs dict
        for k, v in inputs.iteritems():
            key = k.replace('.', '_')
            setattr(self, key, v)
            #print key, getattr(self, key)

    def update_info(self, info_control, info_tuple):
        info_control.begin_time_text.SetLabel(info_tuple[0])
        info_control.end_time_text.SetLabel(info_tuple[1])
        info_control.samples_text.SetLabel(info_tuple[2])

    def step_callback(self, current_info_tuple, cumulative_info_tuple):
        self.update_info(self.current_info, current_info_tuple)
        self.update_info(self.cumulative_info, cumulative_info_tuple)

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

    def create_panels(self):
        """layout panels"""
        self.input_panel = StripChartInputPanel(self, self.log, StripChartInputGrid, self.rt_params)
        self.input_panel.grid
        self.input_panel.run_btn.Hide()
        
        self.output_panel = wx.Panel(self)
        self.output_panel.Hide()
        
        self.sizer = wx.BoxSizer(wx.VERTICAL)
        self.sizer.Add(self.input_panel, 1, wx.EXPAND)
        self.sizer.Add(self.output_panel, 1, wx.EXPAND)
        self.SetSizer(self.sizer)        

        Publisher().subscribe(self.switch_panels, "switch")
        
        self.init_plot()
        self.canvas = FigCanvas(self.output_panel, -1, self.fig)

        self.get_inputs()
        self.xmin_control = BoundControlBox(self.output_panel, -1, "X min", 0)
        self.xmax_control = BoundControlBox(self.output_panel, -1, "X max", 120) #self.rt_params['time.plot_span'])
        self.ymin_control = BoundControlBox(self.output_panel, -1, "Y min", 0)
        self.ymax_control = BoundControlBox(self.output_panel, -1, "Y max", 9000)
        self.current_info = BeginEndSamplesBox(self.output_panel, -1, "Current")
        self.cumulative_info = BeginEndSamplesBox(self.output_panel, -1, "Cumulative")        

        self.step_button = wx.Button(self.output_panel, -1, "Step")
        self.Bind(wx.EVT_BUTTON, self.on_step_button, self.step_button)
        self.Bind(wx.EVT_UPDATE_UI, self.on_update_step_button, self.step_button)
        
        self.pause_button = wx.Button(self.output_panel, -1, "Pause")
        self.Bind(wx.EVT_BUTTON, self.on_pause_button, self.pause_button)
        self.Bind(wx.EVT_UPDATE_UI, self.on_update_pause_button, self.pause_button)
        
        self.cb_grid = wx.CheckBox(self.output_panel, -1, "Show Grid", style=wx.ALIGN_RIGHT)
        self.Bind(wx.EVT_CHECKBOX, self.on_cb_grid, self.cb_grid)
        self.cb_grid.SetValue(True)
        
        self.cb_xlab = wx.CheckBox(self.output_panel, -1, "Show X labels", style=wx.ALIGN_RIGHT)
        self.Bind(wx.EVT_CHECKBOX, self.on_cb_xlab, self.cb_xlab)        
        self.cb_xlab.SetValue(False)

        self.switch_btn = wx.Button(self.output_panel, -1, "Show Inputs")
        self.switch_btn.Bind(wx.EVT_BUTTON, self.switchback)        
        
        # hbox1 for buttons and checkbox controls    
        self.hbox1 = wx.BoxSizer(wx.HORIZONTAL)
        self.hbox1.Add(self.switch_btn, border=5, flag=wx.ALL | wx.ALIGN_CENTER_VERTICAL)
        self.hbox1.AddSpacer(10)
        self.hbox1.Add(self.step_button, border=5, flag=wx.ALL | wx.ALIGN_CENTER_VERTICAL)
        self.hbox1.AddSpacer(10)
        self.hbox1.Add(self.pause_button, border=5, flag=wx.ALL | wx.ALIGN_CENTER_VERTICAL)
        self.hbox1.AddSpacer(10)        
        self.hbox1.Add(self.cb_grid, border=5, flag=wx.ALL | wx.ALIGN_CENTER_VERTICAL)
        self.hbox1.AddSpacer(10)
        self.hbox1.Add(self.cb_xlab, border=5, flag=wx.ALL | wx.ALIGN_CENTER_VERTICAL)
        
        # hbox2 for xy min/max controls, and current/cumulative info
        self.hbox2 = wx.BoxSizer(wx.HORIZONTAL)
        self.hbox2.Add(self.xmin_control, border=5, flag=wx.ALL)
        self.hbox2.Add(self.xmax_control, border=5, flag=wx.ALL)
        self.hbox2.AddSpacer(24)
        self.hbox2.Add(self.ymin_control, border=5, flag=wx.ALL)
        self.hbox2.Add(self.ymax_control, border=5, flag=wx.ALL)
        self.hbox2.AddSpacer(30)
        self.hbox2.Add(self.current_info, border=5, flag=wx.ALL)
        self.hbox2.AddSpacer(24)
        self.hbox2.Add(self.cumulative_info, border=5, flag=wx.ALL)
        
        self.vbox = wx.BoxSizer(wx.VERTICAL)
        self.vbox.Add(self.hbox1,  0, flag=wx.ALIGN_LEFT | wx.TOP)
        self.vbox.Add(self.hbox2,  0, flag=wx.ALIGN_LEFT | wx.TOP)
        self.vbox.Add(self.canvas, 5, flag=wx.LEFT | wx.TOP | wx.GROW)        
        
        self.output_panel.SetSizer(self.vbox)
        self.vbox.Fit(self)
    
    def switchback(self, event):
        """Callback for panel switch button."""
        Publisher.sendMessage("switch", "message")
    
    def on_switch_panels(self, event):
        """"""
        id = event.GetId()
        self.switch_panels(id)
        
    def switch_panels(self, msg=None):
        """switch panels"""
        if self.input_panel.IsShown():
            self.get_inputs()
            
            self.SetTitle("Output Panel")
            self.input_panel.Hide()
            self.output_panel.Show()
            self.sizer.Layout()
        else:
            self.SetTitle("Input Panel")
            self.input_panel.Show()
            self.output_panel.Hide()
        self.Fit()
        self.Layout()

    def create_status_bar(self):
        self.statusbar = self.CreateStatusBar(2, 0)        
        self.statusbar.SetStatusWidths([-1, 300])
        self.statusbar.SetStatusText("Ready", SB_LEFT)

    def getTimeString(self):
        return datetime.datetime.now().strftime('%d-%b-%Y,%j/%H:%M:%S ')

    def notify(self):
        """ Timer event """
        t = self.getTimeString() + ' (update every ' + str(int(SB_MSEC/1000.0)) + 's)'
        self.SetStatusText(t, SB_RIGHT)

    def set_plot_title(self, title):
        """use datagen header_string to set plot title"""
        self.axes['x'].set_title(title, size=16)

    def init_plot(self):
        """initialize the plot"""
        self.axes_labels = ['x', 'y', 'z']
        self.dpi = self.rt_params['figure.dpi']
        self.fig = Figure(self.rt_params['figure.figsize'], dpi=self.dpi)

        rect = self.fig.patch
        rect.set_facecolor('white') # works with plt.show(), but not plt.savefig

        self.axes = {}
        self.axes['x'] = self.fig.add_subplot(3,1,1)
        for i, ax in enumerate(self.axes_labels[1:]):
            self.axes[ax] = self.fig.add_subplot(3, 1, i+2, sharex=self.axes['x'], sharey=self.axes['x'])
            self.axes[ax].set_axis_bgcolor('white')
        self.set_plot_title('init_plot (no first header yet)')
        
        #pylab.setp(self.axes.get_xticklabels(), fontsize=14)
        #pylab.setp(self.axes.get_yticklabels(), fontsize=14)

        # plot the data as a line series, and save the reference 
        # to the plotted line series
        #
        x = np.array([unix2dtm(u) for u in [
            UTCDateTime(2013, 12, 31, 23, 56, 0),
            UTCDateTime(2013, 12, 31, 23, 58, 0),
            UTCDateTime(2014,  1,  1,  0,  0, 0),
            UTCDateTime(2014,  1,  1,  0,  2, 0),
            UTCDateTime(2014,  1,  1,  0,  4, 0),
            UTCDateTime(2014,  1,  1,  0,  6, 0)] ])
        y = np.zeros(x.shape)
        
        # Plotting goes here ...
        self.plot_data = {}
        for ax in self.axes_labels:
            self.plot_data[ax] = self.axes[ax].plot_date(x, y, '-', linewidth=1, color=(1,0,0))[0]
            
        # Set major x ticks every 30 minutes, minor every 15 minutes
        self.axes['z'].xaxis.set_major_locator( matplotlib.dates.MinuteLocator(interval=2) )
        self.axes['z'].xaxis.set_minor_locator( matplotlib.dates.MinuteLocator(interval=1) )
        self.axes['z'].xaxis.set_major_formatter( matplotlib.dates.DateFormatter('%H:%M:%S\n%d-%b-%Y') )
        self.axes['z'].xaxis.set_minor_formatter( matplotlib.dates.DateFormatter('%H:%M:%S') )
        
        ### One can supply an argument to AutoMinorLocator to
        ### specify a fixed number of minor intervals per major interval, e.g.:
        ### minorLocator = AutoMinorLocator(2)
        ### would lead to a single minor tick between major ticks.
        ##minorLocator   = AutoMinorLocator(5)
        ##self.axes['z'].xaxis.set_minor_locator(minorLocator)
        
        # Make tick_params more suitable to your liking...
        plt.tick_params(axis='both', which='both', width=2, direction='out')
        # tick_params for x-axis
        plt.tick_params(axis='x', which='major', labelsize=12, length=8)
        plt.tick_params(axis='x', which='minor', labelsize=9)
        plt.tick_params(axis='x', which='minor', length=6, colors='gray')
        # tick_params for y-axis
        plt.tick_params(axis='y', which='both', labelsize=12)
        plt.tick_params(right=True, labelright=True)

        self.axes['x'].tick_params(axis='x', which='minor', labelsize=0, direction='out', length=6)
        self.axes['y'].tick_params(axis='x', which='minor', labelsize=0, direction='out', length=6)

        # only apply GMT xlabel to z-axis
        self.axes['z'].set_xlabel('GMT')
        
        # to save fig with same facecolor as rt plot, use:
        #fig.savefig('whatever.png', facecolor=fig.get_facecolor(), edgecolor='none')

        self.log.debug('GraphFrame.init_plot() is complete.')

    def draw_plot(self):
        """ Redraws the plot"""
        
        t, x = self.datagen.rt_trace['x'].slice_after(0)
        t, y = self.datagen.rt_trace['y'].slice_after(0)
        t, z = self.datagen.rt_trace['z'].slice_after(0)

        # when xmin is on auto, it "follows" xmax to produce a 
        # sliding window effect. therefore, xmin is assigned after
        # xmax.
        #
        if False:
            if self.xmax_control.is_auto():
                xmax = len(self.data) if len(self.data) > self.rt_params['time.plot_span'] else self.rt_params['time.plot_span']
            else:
                xmax = int(self.xmax_control.manual_value())
                
            if self.xmin_control.is_auto():            
                xmin = xmax - self.rt_params['time.plot_span']
            else:
                xmin = int(self.xmin_control.manual_value())

        # for ymin and ymax, find the minimal and maximal values
        # in the data set and add a mininal margin.
        # 
        # note that it's easy to change this scheme to the 
        # minimal/maximal value in the current display, and not
        # the whole data set.
        # 
        if self.ymin_control.is_auto():
            ymin = round(min(x), 0) - 1
        else:
            ymin = int(self.ymin_control.manual_value())
        
        if self.ymax_control.is_auto():
            ymax = round(max(x), 0) + 1
        else:
            ymax = int(self.ymax_control.manual_value())

        xmin = min(t)
        xmax = max(t)
        self.axes['x'].set_xbound(lower=xmin, upper=xmax)
        self.axes['x'].set_ybound(lower=ymin, upper=ymax)
        
        # anecdote: axes.grid assumes b=True if any other flag is
        # given even if b is set to False.
        # so just passing the flag into the first statement won't
        # work.
        #
        if self.cb_grid.IsChecked():
            self.axes['x'].grid(True, color='gray')
            self.axes['y'].grid(True, color='gray')
            self.axes['z'].grid(True, color='gray')
        else:
            self.axes['x'].grid(False)
            self.axes['y'].grid(False)
            self.axes['z'].grid(False)
            
        self.plot_data['x'].set_xdata( t )
        self.plot_data['x'].set_ydata( x )
        
        self.plot_data['y'].set_xdata( t )
        self.plot_data['y'].set_ydata( y )
        
        self.plot_data['z'].set_xdata( t )
        self.plot_data['z'].set_ydata( z )

        # Using setp here is convenient, because get_xticklabels
        # returns a list over which one needs to explicitly 
        # iterate, and setp already handles this.
        #
        #pylab.setp(self.axes['x'].get_xticklabels(), visible=self.cb_xlab.IsChecked())
        plt.setp(self.axes['x'].get_xticklabels(), visible=self.cb_xlab.IsChecked())
        plt.setp(self.axes['y'].get_xticklabels(), visible=self.cb_xlab.IsChecked())

        self.canvas.draw()

        ## it takes bout 50ms to redraw plot
        #self.log.debug('done redrawing plot')

        #MINDLEN, MAXDLEN = 50, 90
        #if len(self.data) >= MINDLEN and len(self.data) < MAXDLEN:
        #    #self.fig.savefig('/tmp/whatever%04d.png' % len(self.data), facecolor=self.fig.get_facecolor(), edgecolor='none')
        #    self.save_screenshot('/tmp/whatever%04d.png' % len(self.data))
    
    def on_step_button(self, event):
        if self.paused:
            self.data.append( self.datagen.next(self.step_callback) )
            self.draw_plot()
    
    def on_update_step_button(self, event):
        if self.paused:
            self.step_button.Enable()
        else:
            self.step_button.Disable()
    
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
    
    def on_redraw_timer(self, event):
        # if paused do not add data, but still redraw the plot
        # (to respond to scale modifications, grid change, etc.)
        if not self.paused:
            BENCH_STEP.start()
            self.data.append( self.datagen.next(self.step_callback) )
            self.flash_status_message(str(BENCH_STEP), 2000)
        self.draw_plot()
    
    def on_exit(self, event):
        self.Destroy()
    
    def flash_status_message(self, msg, flash_len_ms=1500):
        self.statusbar.SetStatusText(msg)
        self.timeroff = wx.Timer(self)
        self.Bind(
            wx.EVT_TIMER, 
            self.on_flash_status_off, 
            self.timeroff)
        self.timeroff.Start(flash_len_ms, oneShot=True)
    
    def on_flash_status_off(self, event):
        self.statusbar.SetStatusText('')

    def save_screenshot(self, fileName):
        """ Takes a screenshot of the screen at give pos & size (rect). """
        print 'Taking screenshot...'
        rect = self.GetRect()
        # see http://aspn.activestate.com/ASPN/Mail/Message/wxpython-users/3575899
        # created by Andrea Gavana
 
        # adjust widths for Linux (figured out by John Torres 
        # http://article.gmane.org/gmane.comp.python.wxpython/67327)
        if sys.platform == 'linux2':
            client_x, client_y = self.ClientToScreen((0, 0))
            border_width = client_x - rect.x
            title_bar_height = client_y - rect.y
            rect.width += (border_width * 2)
            rect.height += title_bar_height + border_width
 
        #Create a DC for the whole screen area
        dcScreen = wx.ScreenDC()
 
        #Create a Bitmap that will hold the screenshot image later on
        #Note that the Bitmap must have a size big enough to hold the screenshot
        #-1 means using the current default colour depth
        bmp = wx.EmptyBitmap(rect.width, rect.height)
 
        #Create a memory DC that will be used for actually taking the screenshot
        memDC = wx.MemoryDC()
 
        #Tell the memory DC to use our Bitmap
        #all drawing action on the memory DC will go to the Bitmap now
        memDC.SelectObject(bmp)
 
        #Blit (in this case copy) the actual screen on the memory DC
        #and thus the Bitmap
        memDC.Blit( 0, #Copy to this X coordinate
                    0, #Copy to this Y coordinate
                    rect.width, #Copy this width
                    rect.height, #Copy this height
                    dcScreen, #From where do we copy?
                    rect.x, #What's the X offset in the original DC?
                    rect.y  #What's the Y offset in the original DC?
                    )
 
        #Select the Bitmap out of the memory DC by selecting a new
        #uninitialized Bitmap
        memDC.SelectObject(wx.NullBitmap)
 
        img = bmp.ConvertToImage()
        #fileName = "/tmp/myImage.png"
        img.SaveFile(fileName, wx.BITMAP_TYPE_PNG)
        #print '...saving as png!'

def demo_pad_gen():
    from pims.pad.packetfeeder import PadGenerator
    from pims.realtime import rt_params
    
    app = wx.PySimpleApp()
    log = SimpleLog('pims.gui.stripchart.demo_pad_gen', log_level='DEBUG').log
    log.info('Logging started.')
    #app.frame = GraphFrame(DataGenExample(), 'title', log, rt_params)
    app.frame = GraphFrame(DataGenBetterExample(), 'title', log, rt_params)
    #app.frame = GraphFrame(PadGenerator(), 'title', log, rt_params)
    app.frame.Show()
    app.MainLoop()        

def demo_callback(curr_info, cum_info):
    print curr_info, cum_info
    
def demo_datagen_with_time_arr():
    dg = DataGenBetterExample(scale_factor=0.1, num_splits=4)
    for i in range(1000):
        if i < 3 or i > 746:
            cb = demo_callback
        else:
            cb = None
        t, a = dg.next(step_callback=cb)

if __name__ == '__main__':
    
    #demo_datagen_with_time_arr()
    demo_pad_gen()
    

#-----------------------------------
#FIRST PACKET
#-----------------------------------
#SAMS2, 121f05, X-axis
#JPM1F5, ER4, Drawer 2
#sample_rate 500 (Hz > sps)
#
#-----------------------------------
#THIS PACKET 0279
#-----------------------------------
#BEGINS: 2013-09-09T15:20:15.672885Z
#ENDS:   2013-09-09T15:20:15.818885Z
#74 samples
#packetGap: 0.1480000019
#sampleGap: 0.0020000935
#
#-----------------------------------
#CUMULATIVE REAL-TIME TRACE
#-----------------------------------
#BEGINS: 2013-09-09T15:20:15.672885Z
#ENDS:   2013-09-09T15:20:15.818885Z
#74 samples
#
#-----------------------------------
#MISC
#-----------------------------------
#TOTAL_PACKETS_FED
#NEXT_COUNT