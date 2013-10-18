#!/usr/bin/env python
"""
PAD Headers.
"""

import os
from datetime import timedelta
from interval import Interval
from pims.lib.tools import TransformedDict
from pims.pad.parsenames import match_header_filename
from pims.utils.pimsdateutil import timestr_to_datetime
from pims.utils.pimsdateutil import datetime_to_pad_ymd_subdir
from pims.core.files.utils import listdir_filename_pattern
from pims.utils.iteratortools import pairwise
from create_header_dict import parse_header # FIXME old [but trusted] code

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
        self.sensor = sensor
        self.desired_start = desired_start
        self.pad_dir = pad_dir
        self.header_file = self._find_the_right_header_file()
        self.dict = parse_header(self.header_file)
        
    def _find_the_right_header_file(self):
        """
        Get list of header files from day before desired_start through day after, then
        use pairwise (ftw) to check through those header files.  The one we want is in
        the following time range:
         
               O-------------*
        |__1___|     |___2___|
          prev         THIS
           hdr          hdr!
         
        """
        # Get 3 days worth of header files
        hdr_files = []
        base_date = self.desired_start.date()
        for day in [ base_date + timedelta(days=x) for x in range(-1, 2) ]:
            hdr_files += self._get_header_files_for_date(day)

        # Iterate pairwise to find the right one to use
        hdr_file = None
        for hdr1, hdr2 in pairwise(hdr_files):
            match1, match2 = [ match_header_filename(f) for f in [hdr1, hdr2] ]
            # Parse each of first/last header to get lower and upper bound of day interval
            stop1_str = match1.group('stop_str')
            stop2_str = match2.group('stop_str')
            # Convert time strings to datetime objects
            t1 = timestr_to_datetime(stop1_str)
            t2 = timestr_to_datetime(stop2_str)
            if self.desired_start > t1 and self.desired_start <= t2:
                #print "*", t1, "to", t2, "<<<", self.desired_start
                hdr_file = hdr2
                break
        return hdr_file

    def __str__(self): return '%s for %s at %s' % (self.__class__.__name__, self.sensor, self.desired_start)   

    def __repr__(self): return self.__str__()
    
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

def demo():
    ph = PadHeader( '121f03006', datetime(2012, 12, 31, 11, 59, 59, 999000) )
    print ph.dict
    #print PadHeader( '121f03006', datetime(2012, 12, 31, 0, 5, 0) ).header_file
    #print PadHeader( '121f03006', datetime(2012, 12, 31, 23, 57, 0) ).header_file
    
if __name__ == "__main__":
    from datetime import datetime
    import doctest
    if False:
        doctest.testmod()
    else:
        demo()
    pass
    