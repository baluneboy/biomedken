#!/usr/bin/env python
"""
Populate wx grid structure with days as rows, sensors as columns, and percents as cell values.
"""

from dateutil import parser
from datetime_ranger import DateRange

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
