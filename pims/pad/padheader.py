#!/usr/bin/env python
"""
PAD Header classes.
"""

from interval import Interval
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
    
    """
    def __init__(self, sensor, desired_start):
        self.sensor = sensor
        self.desired_start = desired_start
        self._day_interval = self._get_day_interval()
        
        # Use sensor and desired start datetime to get header dict
        self.dict = self._get_dict()

    def __str__(self): return '%s for %s at %s' % (self.__class__.__name__, self.sensor, self.desired_start)   

    def __repr__(self): return self.__str__()
    
    def _get_dict(self):
        """Use sensor and desired start to get totally dict."""
        return {'sensor': self.sensor, 'desired_start': self.desired_start}
    
    def _get_day_interval(self):
        """Use date part of desired_start to get interval from first file start to last file end time."""

        desired_date = self.desired_start.date()

        #hdr_files = listdir_filename_pattern(pth, fname_pattern)        
        #hdr_files.sort()
        
        return None
    
if __name__ == "__main__":
    from datetime import datetime
    import doctest
    doctest.testmod(verbose=True)
    