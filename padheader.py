#!/usr/bin/env python
"""
PAD Headers.
"""

import os
from interval import Interval
from pims.pad.parsenames import match_header_filename
from pims.utils.pimsdateutil import timestr_to_datetime
from pims.utils.pimsdateutil import datetime_to_pad_ymd_subdir
from pims.core.files.utils import listdir_filename_pattern

class PadHeader(object):
    """
    Given sensor designation and starting datetime, grab unique header (leader).
    
    Examples
    --------
    
    >>> print PadHeader( '121f03006', datetime(2013, 1, 1))
    PadHeader for 121f03006 at 2013-01-01 00:00:00
    
    >>> print PadHeader( '121f03006', datetime(2012, 12, 31, 0, 5, 0) )._first_header_file
    /misc/yoda/pub/pad/year2012/month12/day31/sams2_accel_121f03006/2012_12_31_00_06_17.985-2012_12_31_01_23_13.189.121f03006.header
    
    >>> print PadHeader( '121f03006', datetime(2012, 12, 31, 23, 57, 0) )._first_header_file
    /misc/yoda/pub/pad/year2012/month12/day31/sams2_accel_121f03006/2012_12_31_00_06_17.985-2012_12_31_01_23_13.189.121f03006.header

    >>> print PadHeader( '121f03006', datetime(2012, 12, 31, 11, 59, 59, 999000) )._first_header_file
    /misc/yoda/pub/pad/year2012/month12/day31/sams2_accel_121f03006/2012_12_31_00_06_17.985-2012_12_31_01_23_13.189.121f03006.header
    
    """
    def __init__(self, sensor, desired_start, pad_dir='/misc/yoda/pub/pad'):
        self.pad_dir = pad_dir
        self.sensor = sensor
        self.desired_start = desired_start
        self._day_start = self._get_desired_day()
        self.header_file = self._find_starter_header_file()
        
        # Use sensor and desired start datetime to get header dict
        self.dict = self._get_dict()
    
    def _find_starter_header_file(self):
        """Find the first header file with start time >= desired_start."""
        for hdr_file in self.hdr_files_same_day:
            m = match_header_filename(hdr_file)
            start_str, stop_str = m.group('start_str'), m.group('stop_str')
            start_datetime = timestr_to_datetime(start_str)
            stop_datetime = timestr_to_datetime(stop_str)
            hdr_file_interval = Interval(start_datetime, stop_datetime)
            print self.desired_start, hdr_file_interval
            if self.desired_start in hdr_file_interval:
                return hdr_file
        return None
    
    def _get_desired_day(self):
        """We may need to go to previous or next day the way PAD stream gets chopped."""
        day_interval = self._get_day_interval() # created from PAD header filename times
        desired_start_as_interval = Interval(self.desired_start, self.desired_start) # needed for compare
        if self.desired_start in day_interval:
            # same day, find first header with start time >= desired_start
            hdr_file = self._find_starter_header_file()
        elif desired_start_as_interval.comes_before(day_interval):
            # desired_start before day_interval, SO USE LAST header from PREVIOUS day
            hdr_file = None # for now
        else:
            # desired_start not in AND not before SO USE FIRST header from NEXT day
            hdr_file = None # for now
        return hdr_file or None

    def __str__(self): return '%s for %s at %s' % (self.__class__.__name__, self.sensor, self.desired_start)   

    def __repr__(self): return self.__str__()
    
    def _get_dict(self):
        """Use sensor and desired start to get totally dict."""
        return {
            'sensor': self.sensor,
            'desired_start': self.desired_start,
            }
    
    def _get_header_files_for_date(self, d):
        """Get header files for given sensor on d day."""
        # Components of PAD path pattern
        ymd_subdir = os.path.join( self.pad_dir, datetime_to_pad_ymd_subdir(d) )
        sys_sensor_pattern = '(?P<system>.*)_accel_%s\Z' % self.sensor
        
        # Verify exactly one subdir matches pattern
        matching_dirs = listdir_filename_pattern(ymd_subdir, sys_sensor_pattern)
        if len(matching_dirs) != 1: return None
        sensor_dir = matching_dirs[0]
        
        # Get header files
        header_pattern = '.*\.%s\.header' % self.sensor
        return listdir_filename_pattern(sensor_dir, header_pattern)        
    
    # FIXME consolidate with _find_starter_header_file code
    def _get_day_interval(self):
        """Use date part of desired_start to get interval from first file start to last file end time."""
        # Get header files for desired_start's date
        hdr_files = self._get_header_files_for_date( self.desired_start.date() )
        match_hdr_file_first, match_hdr_file_last = [match_header_filename(f) for f in [hdr_files[0], hdr_files[-1]] ]
        self.hdr_files_same_day = hdr_files
        
        # Parse each of first/last header to get lower and upper bound of day interval
        if match_hdr_file_first and match_hdr_file_last:
            start_str = match_hdr_file_first.group('start_str')
            stop_str = match_hdr_file_last.group('stop_str')
        else:
            return None
        
        # Convert time strings to datetime objects
        start_datetime = timestr_to_datetime(start_str)
        stop_datetime = timestr_to_datetime(stop_str)
        
        return Interval(start_datetime, stop_datetime)

def demo():
    #print PadHeader( '121f03006', datetime(2012, 12, 31, 11, 59, 59, 999000) ).header_file
    #print PadHeader( '121f03006', datetime(2012, 12, 31, 0, 5, 0) ).header_file
    print PadHeader( '121f03006', datetime(2012, 12, 31, 23, 57, 0) ).header_file
    #print ph_too_early
    #print ph_too_late
    #print ph
    
if __name__ == "__main__":
    from datetime import datetime
    import doctest
    if False:
        doctest.testmod()
    else:
        demo()
    pass
    