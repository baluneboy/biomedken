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
    
    >>> PadHeader( '121f03', datetime(2013, 1, 2) )
    PadHeader for 121f03 at 2013-01-02 00:00:00
    
    >>> print PadHeader( '121f03006', datetime(2012, 12, 31, 23, 59, 59, 999000) ).dict
    {'desired_start': datetime.datetime(2012, 12, 31, 23, 59, 59, 999000), 'sensor': '121f03006'}
    
    >>> print PadHeader( '121f03006', datetime(2012, 12, 31, 23, 59, 59, 999000) ).day_interval
    [datetime.datetime(2012, 12, 31, 0, 6, 17, 985000)..datetime.datetime(2012, 12, 31, 23, 56, 28, 423000)]

    >>> print PadHeader( '121f03006', datetime(2012, 12, 31, 23, 55, 59, 999000) )._is_date_in_day_interval(datetime(2012, 12, 31, 0, 11, 35))
    True
    
    """
    def __init__(self, sensor, desired_start, pad_dir='/misc/yoda/pub/pad'):
        self.pad_dir = pad_dir
        self.sensor = sensor
        self.desired_start = desired_start
        self.day_interval = self._get_day_interval()
        if not desired_start in self.day_interval:
            # check day before or after
            print '--> %s NOT in %s' % (desired_start, self.day_interval)
        
        # Use sensor and desired start datetime to get header dict
        self.dict = self._get_dict()

    def __str__(self): return '%s for %s at %s' % (self.__class__.__name__, self.sensor, self.desired_start)   

    def __repr__(self): return self.__str__()
    
    def _get_dict(self):
        """Use sensor and desired start to get totally dict."""
        return {'sensor': self.sensor, 'desired_start': self.desired_start}
        
    def _get_day_interval(self):
        """Use date part of desired_start to get interval from first file start to last file end time."""
        # Components of PAD path pattern
        desired_date = self.desired_start.date()
        ymd_subdir = os.path.join( self.pad_dir, datetime_to_pad_ymd_subdir(desired_date) )
        sys_sensor_pattern = '(?P<system>.*)_accel_%s\Z' % self.sensor
        
        # Verify exactly one subdir matches pattern
        matching_dirs = listdir_filename_pattern(ymd_subdir, sys_sensor_pattern)
        if len(matching_dirs) != 1: return None
        sensor_dir = matching_dirs[0]
        
        # Get first and last header file
        header_pattern = '.*\.%s\.header' % self.sensor
        hdr_files = listdir_filename_pattern(sensor_dir, header_pattern)        
        match_hdr_file_first, match_hdr_file_last = [match_header_filename(f) for f in [hdr_files[0], hdr_files[-1]] ]
        
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
    ph = PadHeader( '121f03006', datetime(2012, 12, 31, 23, 59, 59, 999000) )
    print ph
    
if __name__ == "__main__":
    from datetime import datetime
    import doctest
    #doctest.testmod(verbose=True)
    demo()
    pass
    