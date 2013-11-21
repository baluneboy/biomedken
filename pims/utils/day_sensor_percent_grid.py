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
from pims.patterns.dailyproducts import _BATCHROADMAPS_PATTERN, _PADHEADERFILES_PATTERN
from pims.utils.pimsdateutil import timestr_to_datetime

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
    
    def __init__(self, date_range, pattern='.*_121f0\d{1}.*_.*roadmaps.*\.pdf$', basepath='/misc/yoda/www/plots/batch'):
        super(VibratoryRoadmapsGrid, self).__init__(date_range)
        self.pattern = pattern
        self.basepath = basepath

    # FIXME this can be made generic
    def pivot_table_insert_day_entries(self, d):
        """Walk ymd path and insert regex matches of filename pattern into data frame."""
        dirpath = os.path.join( self.basepath, d.strftime('year%Y/month%m/day%d') )
        fullfile_pattern = os.path.join(dirpath, self.pattern)
        for f in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
            dtm, sensor, abbrev, bname = self.parse_basename(f)
            self.data_frame.insert({'date':dtm.date(), 'hour':dtm.hour, 'sensor':sensor, 'abbrev':abbrev, 'bname':bname, 'fname':f})
    
    def parse_basename(self, f):
        """Parse file basename."""
        m = re.match(_BATCHROADMAPS_PATTERN, f)
        if m:
            dtm = timestr_to_datetime(m.group('dtm'))
            sensor = m.group('sensor')
            abbrev = m.group('abbrev')
            return dtm, sensor, abbrev, os.path.basename(f)
        else:
            return 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', "%s" % os.path.basename(f)
    
    def fill_data_frame(self):
        """Populate data frame day-by-day."""
        d = self.date_range.start
        while d <= self.date_range.stop:
            self.pivot_table_insert_day_entries(d)
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

class PadHeaderFilesGrid(VibratoryRoadmapsGrid):
    """
    A grid with days as rows, sensors as columns, & number of PAD header files as cell values.
    """    
    
    def __init__(self, date_range, pattern='.*\.header$', basepath='/misc/yoda/pub/pad'):
        super(PadHeaderFilesGrid, self).__init__(date_range)
        self.pattern = pattern
        self.basepath = basepath

    def parse_basename(self, f):
        """Parse file basename."""
        m = re.match(_PADHEADERFILES_PATTERN, f)
        if m:
            start = timestr_to_datetime(m.group('start'))
            stop = timestr_to_datetime(m.group('stop'))
            sensor = m.group('sensor')
            return start, stop, sensor, os.path.basename(f)
        else:
            return 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', "%s" % os.path.basename(f)

    # FIXME this can be made generic
    def pivot_table_insert_day_entries(self, d):
        """Walk ymd path and insert regex matches of filename pattern into data frame."""
        dirpath = os.path.join( self.basepath, d.strftime('year%Y/month%m/day%d') )
        fullfile_pattern = os.path.join(dirpath, self.pattern)
        for f in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
            start, stop, sensor, bname = self.parse_basename(f)
            span_hours = (stop - start).seconds / 3600.0
            self.data_frame.insert({'date':start.date(), 'span_hours':span_hours, 'sensor':sensor, 'bname':bname, 'fname':f})

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
    show_grid(day_rows, sensor_columns, rows)

def spgdot_roadmaps_gridify(date_range, pattern='.*_pcss_roadmaps.*\.pdf$'):
    
    vgrid = VibratoryRoadmapsGrid(date_range, pattern=pattern)
    vgrid.fill_data_frame()
    pt = vgrid.get_pivot_table()
    
    day_rows = [ str(i[0][1]) for i in pt.rnames]
    sensor_columns = [ str(i[0][1]) for i in pt.cnames]
    rows = [ i for i in pt ]
    show_grid(pattern, day_rows, sensor_columns, rows)

def pad_hours_gridify(date_range, pattern='.*\.header$'):
    
    vgrid = PadHeaderFilesGrid(date_range, pattern=pattern, basepath='/misc/yoda/pub/pad')
    vgrid.fill_data_frame()
    pt = vgrid.get_pivot_table(val='span_hours', rows=['date'], cols=['sensor'], aggregate='sum')
    
    day_rows = [ str(i[0][1]) for i in pt.rnames]
    sensor_columns = [ str(i[0][1]) for i in pt.cnames]
    rows = [ i for i in pt ]
    show_grid(pattern, day_rows, sensor_columns, rows)

def show_grid(pattern, rlabels, clabels, rows):
    app = wx.PySimpleApp()
    frame = TestFrame(None, sys.stdout, pattern, rlabels, clabels, rows)
    frame.Show(True)
    app.MainLoop()

if __name__ == "__main__":
    #import doctest
    #doctest.testmod(verbose=True)

    #d1 = parser.parse('2013-10-22').date()
    ##d2 = parser.parse('2013-11-19').date()
    #d2 = datetime.date.today()-datetime.timedelta(days=2)
    #date_range = DateRange(start=d1, stop=d2)
    #spgdot_roadmaps_gridify(date_range, pattern='.*_spg._roadmaps.*\.pdf$')
    
    d1 = parser.parse('2013-10-22').date()
    #d2 = parser.parse('2013-11-19').date()
    d2 = datetime.date.today()-datetime.timedelta(days=2)
    date_range = DateRange(start=d1, stop=d2)    
    pad_hours_gridify(date_range, pattern='.*121f0[35]006\.header$')
