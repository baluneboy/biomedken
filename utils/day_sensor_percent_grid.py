#!/usr/bin/env python
"""
Populate wx grid structure with days as rows, sensors as columns, and percents as cell values.
"""

# FIXME must have one row for each day (no skips)

import os
import re
import wx
import sys
from pims.gui.percent_grid import TallyFrame, TallyGrid
import datetime
from dateutil import parser
from datetime_ranger import DateRange
from pims.files.utils import filter_filenames, parse_roadmap_filename
from pyvttbl import DataFrame
from pims.patterns.dailyproducts import _BATCHROADMAPS_PATTERN, _PADHEADERFILES_PATTERN
from pims.utils.pimsdateutil import timestr_to_datetime

class RoadmapGrid(object):
    """A grid with days as rows, sensors as columns, & file count as cell values."""    

    def __init__(self, date_range,
                 #pattern='.*roadmap.*\.pdf$',
                 pattern=_BATCHROADMAPS_PATTERN,
                 basepath='/misc/yoda/www/plots/batch'):
        self.date_range = date_range
        self.pattern = pattern
        self.basepath = basepath
        self.title = self.__class__.__name__ + ' for "%s"' % self.pattern
        self.data_frame = DataFrame()
        
    def __str__(self): return 'This is a %s for %s.\n' % (self.title, self.date_range)

    def __repr__(self): return self.__str__()

    def pivot_table_insert_day_entries(self, d):
        """Walk ymd path and insert regex matches of filename pattern into data frame."""
        dirpath = os.path.join( self.basepath, d.strftime('year%Y/month%m/day%d') )
        fullfile_pattern = os.path.join(dirpath, self.pattern)
        bool_got_match = False
        for f in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
            dfin = self.get_dict_for_insert(f)
            self.data_frame.insert(dfin)
            bool_got_match = True
        if not bool_got_match:
            # do not skip any days/rows, insert dummy dict for dfin
            self.data_frame.insert({'date':d, 'hour':None, 'sensor':None, 'abbrev':None, 'bname':None, 'fname':None})
                
    def get_dict_for_insert(self, f):
        """Get dict to use for data frame insertion."""
        tup = self.parse_basename(f)
        dtm, sensor, abbrev, bname = tup
        return {'date':dtm.date(), 'hour':dtm.hour, 'sensor':sensor, 'abbrev':abbrev, 'bname':bname, 'fname':f}
    
    
    # FIXME this can be made generic
    def parse_basename(self, f):
        """Parse file basename."""
        m = re.match(self.pattern, f)
        # FIXME for generic, tuple's group fields can be list input to class init
        if m:
            dtm = timestr_to_datetime(m.group('dtm'))
            sensor = m.group('sensor')
            abbrev = m.group('abbrev')
        else:
            dtm, sensor, abbrev = None, None, None
        return (dtm, sensor, abbrev, os.path.basename(f))
    
    
    def fill_data_frame(self):
        """Populate data frame day-by-day."""
        d = self.date_range.start
        while d <= self.date_range.stop:
            self.pivot_table_insert_day_entries(d)
            d += datetime.timedelta(days=1)
    
    def get_pivot_table(self, val='abbrev', rows=['date'], cols=['sensor'], aggregate='count'):
        """This is where we pivot."""
        return self.data_frame.pivot(val, rows, cols, aggregate)
    
    def attach(self, other):
        """Attach other DataFrame to this one (both must have the same columns)"""
        # do minimal checking
        if not isinstance(other, RoadmapGrid):
            raise TypeError('second argument must be a RoadmapGrid')
        # perform attachment
        self.data_frame.attach(other.data_frame)

class CheapPadHoursGrid(RoadmapGrid):
    """
    A grid with days as rows, sensors as columns, & number of PAD header files as cell values.
    """    

    # FIXME this can be made generic (see its base class)
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

    # FIXME this can be made generic (see its base class)
    def pivot_table_insert_day_entries(self, d):
        """Walk ymd path and insert regex matches of filename pattern into data frame."""
        dirpath = os.path.join( self.basepath, d.strftime('year%Y/month%m/day%d') )
        fullfile_pattern = os.path.join(dirpath, self.pattern)
        bool_got_match = False
        for f in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
            start, stop, sensor, bname = self.parse_basename(f)
            span_hours = (stop - start).seconds / 3600.0
            self.data_frame.insert({'date':d, 'span_hours':span_hours, 'sensor':sensor, 'bname':bname, 'fname':f})
            bool_got_match = True
        if not bool_got_match:
            # do not skip any days/rows, insert zero span
            self.data_frame.insert({'date':d, 'span_hours':0.0, 'sensor':None, 'bname':None, 'fname':None})

def spgdot_roadmaps_gridify(date_range, pattern=_BATCHROADMAPS_PATTERN, basepath='/misc/yoda/www/plots/batch'):
    
    vgrid = RoadmapGrid(date_range, pattern=pattern, basepath=basepath)
    vgrid.fill_data_frame()
    pt = vgrid.get_pivot_table() # use default pivot parameters
    
    day_rows = [ str(i[0][1]) for i in pt.rnames]
    sensor_columns = [ str(i[0][1]) for i in pt.cnames]
    rows = [ i for i in pt ]
    
    show_grid(vgrid.title, day_rows, sensor_columns, rows, ['None'])

def pad_hours_gridify(date_range, pattern=_PADHEADERFILES_PATTERN, basepath='/misc/yoda/pub/pad'):
    
    vgrid = CheapPadHoursGrid(date_range, pattern=pattern, basepath=basepath)
    vgrid.fill_data_frame()
    # pivot using special pivot parameters
    pt = vgrid.get_pivot_table(val='span_hours', rows=['date'], cols=['sensor'], aggregate='sum')
    
    day_rows = [ str(i[0][1]) for i in pt.rnames]
    sensor_columns = [ str(i[0][1]) for i in pt.cnames]
    temp_rows = [ i for i in pt ]
    
    # replace None's with zero's in the rows
    rows = [ [0 if not x else x for x in r] for r in temp_rows ]
    
    show_grid(vgrid.title, day_rows, sensor_columns, rows, ['None'])

def show_grid(title, rlabels, clabels, rows, exclude_cols):
    app = wx.PySimpleApp()
    frame = TallyFrame(None, sys.stdout, title, rlabels, clabels, rows, exclude_cols)
    frame.Show(True)
    app.MainLoop()

if __name__ == "__main__":
    #import doctest
    #doctest.testmod(verbose=True)

    d1 = parser.parse('2013-09-28').date()
    d2 = parser.parse('2013-10-02').date()
    date_range = DateRange(start=d1, stop=d2)
    pth_field = "(?P<ymdpath>.*)"
    date_field = "(?P<dtm>\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}\.\d{3})"
    sensor_field = "_(?P<sensor>.*)"
    abbrev_field = "_(?P<abbrev>.*)"
    suffix_field = "_roadmaps(?P<rate>.*)\.pdf\Z"
    pattern = pth_field + date_field + sensor_field + abbrev_field + suffix_field
    spgdot_roadmaps_gridify(date_range, pattern)
    raise SystemExit

#------------------------------------

    #d1 = parser.parse('2013-10-18').date()
    ##d2 = parser.parse('2013-11-19').date()
    #d2 = datetime.date.today()-datetime.timedelta(days=2)
    #date_range = DateRange(start=d1, stop=d2)
    #spgdot_roadmaps_gridify(date_range, pattern='.*_spg._roadmaps.*\.pdf$')
    #raise SystemExit

#------------------------------------
    
    d1 = parser.parse('2013-01-01').date()
    d2 = parser.parse('2013-01-05').date()
    #d2 = datetime.date.today()-datetime.timedelta(days=2)
    date_range = DateRange(start=d1, stop=d2)    
    pad_hours_gridify(date_range)
