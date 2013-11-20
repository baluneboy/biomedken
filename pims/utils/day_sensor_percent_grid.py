#!/usr/bin/env python
"""
Populate wx grid structure with days as rows, sensors as columns, and percents as cell values.
"""

import os
import re
import wx
import sys
from pims.gui.percent_grid import VibRoadmapsGrid
import datetime
from dateutil import parser
from datetime_ranger import DateRange
from pims.files.utils import filter_filenames, parse_roadmap_filename
from pyvttbl import DataFrame

class DaySensorPercentGrid(object):
    """
    A grid with days as rows, sensors as columns, and percents as cell values.
    """
    
    def __init__(self, date_range):
        self.date_range = date_range
        self.data_frame = DataFrame()

    def __str__(self): return 'This is a %s for %s.\n' % (self.__class__.__name__, self.date_range)

    def __repr__(self): return self.__str__()

    def _get_sensors(self):
        """Get sensors."""
        raise NotImplementedError('your subclass must implement this method')

    def get_percentages(self):
        """Get percentages with outer loop for days (rows) & inner loop for sensors (cols)."""
        raise NotImplementedError('your subclass must implement this method')
    
class VibratoryRoadmapsGrid(DaySensorPercentGrid):
    """
    A grid with days as rows, vibratory sensors_axis as columns, & percents (in thirds) as cell values.
    """    
    
    def __init__(self, date_range, pattern='.*_121f0\d{1}.*_.*roadmaps.*\.pdf$', batchpath='/misc/yoda/www/plots/batch'):
        super(VibratoryRoadmapsGrid, self).__init__(date_range)
        self.pattern = pattern
        self.batchpath = batchpath

    def pivot_table_insert_day_roadmaps(self, d):
        """Walk ymd path and insert regex matches of filename pattern into data frame."""
        dirpath = os.path.join( self.batchpath, d.strftime('year%Y/month%m/day%d') )
        fullfile_pattern = os.path.join(dirpath, self.pattern)
        for f in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
            dtm, sensor, abbrev, bname = parse_roadmap_filename(f)
            dat = dtm.date()
            hr = dtm.hour
            self.data_frame.insert({'date':dat, 'hour':hr, 'sensor':sensor, 'abbrev':abbrev, 'bname':bname, 'fname':f})
        
    def fill_data_frame(self):
        """Populate data frame day-by-day."""
        d = self.date_range.start
        while d <= self.date_range.stop:
            self.pivot_table_insert_day_roadmaps(d)
            d += datetime.timedelta(days=1)
    
    def get_pivot_table(self, val='abbrev', rows=['date'], cols=['sensor'], aggregate='count'):
        return self.data_frame.pivot(val, rows, cols, aggregate)
    
    def attach(self, other):
        """attaches other DataFrame to this one (both must have the same columns)"""

        # do minimal checking
        if not isinstance(other, VibratoryRoadmapsGrid):
            raise TypeError('second argument must be a VibratoryRoadmapsGrid')
        
        # perform attachment
        self.data_frame.attach(other.data_frame)

class TestFrame(wx.Frame):
    def __init__(self, parent, log, pattern, dayrow_labels, sensorcolumn_labels, rows):
        wx.Frame.__init__(self, parent, -1, pattern, size=(1200, 1000))
        #dayrow_labels = ['2013-10-31', '2013-11-01']
        #sensorcolumn_labels = ['hirap','121f03','121f05onex']
        #rows = [ [0.0, 0.5, 1.0], [0.9, 0.4, 0.2] ]
        self.grid = VibRoadmapsGrid(self, log, dayrow_labels, sensorcolumn_labels, rows)

def ugly_demo2():
    d1 = parser.parse('2013-10-23').date()
    d2 = parser.parse('2013-11-18').date()
    date_range = DateRange(start=d1, stop=d2)
    
    vgrid1 = VibratoryRoadmapsGrid(date_range, pattern='.*_121f0\d{1}_pcss_roadmaps.*\.pdf$')
    vgrid1.fill_data_frame()
    pt1 = vgrid1.get_pivot_table()
    #print pt1
    
    vgrid2 = VibratoryRoadmapsGrid(date_range, pattern='.*_121f0\d{1}one_pcss_roadmaps.*\.pdf$')
    vgrid2.fill_data_frame()
    pt2 = vgrid2.get_pivot_table()
    #print pt2
    
    # combine the two and pivot the combo
    vgrid1.attach(vgrid2)
    pt = vgrid1.get_pivot_table()
    #print pt
    
    day_rows = [ str(i[0][1]) for i in pt.rnames]
    sensor_columns = [ str(i[0][1]) for i in pt.cnames]
    rows = [ i for i in pt ]
    #print day_rows
    #print sensor_columns
    #for r in rows:
    #    print r
    show_grid(day_rows, sensor_columns, rows)

def ugly_demo(pattern='.*_pcss_roadmaps.*\.pdf$'):
    d1 = parser.parse('2013-10-18').date()
    d2 = parser.parse('2013-11-18').date()
    date_range = DateRange(start=d1, stop=d2)
    
    vgrid1 = VibratoryRoadmapsGrid(date_range, pattern=pattern)
    vgrid1.fill_data_frame()
    pt1 = vgrid1.get_pivot_table()
    
    day_rows = [ str(i[0][1]) for i in pt1.rnames]
    sensor_columns = [ str(i[0][1]) for i in pt1.cnames]
    rows = [ i for i in pt1 ]
    show_grid(pattern, day_rows, sensor_columns, rows)

def show_grid(pattern, rlabels, clabels, rows):
    app = wx.PySimpleApp()
    frame = TestFrame(None, sys.stdout, pattern, rlabels, clabels, rows)
    frame.Show(True)
    app.MainLoop()

if __name__ == "__main__":
    #import doctest
    #doctest.testmod(verbose=True)

    ugly_demo(pattern='.*_spg._roadmaps.*\.pdf$')
