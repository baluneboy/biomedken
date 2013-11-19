#!/usr/bin/env python
"""
Populate wx grid structure with days as rows, sensors as columns, and percents as cell values.
"""

import os
import re
import datetime
from dateutil import parser
from datetime_ranger import DateRange
from pims.utils.pimsdateutil import timestr_to_datetime
from pims.patterns.dailyproducts import _BATCHROADMAPS_PATTERN
from pyvttbl import DataFrame

def parse_roadmap_filename(f):
    m = re.match(_BATCHROADMAPS_PATTERN, f)
    if m:
        dtm = timestr_to_datetime(m.group('dtm'))
        sensor = m.group('sensor')
        abbrev = m.group('abbrev')
        return dtm, sensor, abbrev, os.path.basename(f)
    else:
        return 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', "%s" % os.path.basename(f)

#dtm, sensor, abbrev, pth = parse_roadmap_filename('/misc/yoda/www/plots/batch/year2013/month09/day29/2013_09_29_00_00_00.000_121f03_spgs_roadmaps500.pdf')
#print dtm, sensor, abbrev, pth
#raise SystemExit

def pivot_table_insert_day_roadmaps(df, d=datetime.date.today()-datetime.timedelta(days=2), batchpath='/misc/yoda/www/plots/batch', pattern='.*roadmaps.*\.pdf$'):
    """Walk ymd path and insert regex matches of filename pattern into data frame."""
    dirpath = os.path.join( batchpath, d.strftime('year%Y/month%m/day%d') )
    fullfile_pattern = os.path.join(dirpath, pattern)
    for f in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
        dtm, sensor, abbrev, bname = parse_roadmap_filename(f)
        dat = dtm.date()
        hr = dtm.hour
        df.insert({'date':dat, 'hour':hr, 'sensor':sensor, 'abbrev':abbrev, 'bname':bname, 'fname':f})

def demo_pivot_roadmap_pdfs():
    d = datetime.date(2013,8,1)
    dStop = datetime.date(2013,8,19)
    pattern = '.*_121f0\d{1}one_.*roadmaps.*\.pdf$' # '.*roadmaps.*\.pdf$'
    print 'FROM %s TO %s USING PATTERN "%s"' % (str(d), str(dStop), pattern)
    build_pivot_roadmap_pdfs(d, dStop, pattern)
    
def build_pivot_roadmap_pdfs(d, dStop, pattern):
    df = DataFrame()
    while d <= dStop:
        pivot_table_insert_day_roadmaps(df, d=d, pattern=pattern)
        d += datetime.timedelta(days=1)
    pt = df.pivot('abbrev', ['date'],['sensor'], aggregate='count')
    print pt

class DaySensorPercentGrid(object):
    """
    A grid with days as rows, sensors as columns, and percents as cell values.
    """
    
    def __init__(self, date_range):
        self.date_range = date_range

    def __str__(self): return 'This is a %s for %s.\n' % (self.__class__.__name__, self.date_range)

    def __repr__(self): return self.__str__()

    def _get_sensors(self):
        """Get sensors."""
        raise NotImplementedError('your subclass must implement this method')

    def get_percentages(self):
        """Get percentages with outer loop for days (rows) & inner loop for sensors (cols)."""
        raise NotImplementedError('your subclass must implement this method')

if __name__ == '__main__':
    d1 = parser.parse('2013-10-31').date()
    d2 = parser.parse('2013-11-02').date()
    date_range = DateRange(start=d1, stop=d2)
    g = DaySensorPercentGrid(date_range)
    print g
