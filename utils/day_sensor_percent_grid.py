#!/usr/bin/env python
"""
Populate wx grid structure with days as rows, sensors as columns, and percents as cell values.
"""

class DaySensorPercentGrid(object):
    """
    A class to manage grid with days as rows, sensors as columns, and percents as cell values.
    """
    
    def __init__(self, date_range, sensor_getter, percent_getter):
        pass

    def __str__(self): return '%s isa %s\n' % (self.name, self.__class__.__name__)   

    def __repr__(self): return self.__str__()

    def _get_notes(self): return self._match.group('notes') or 'empty'

    def _get_plot_type(self): return _PLOTTYPES['']

if __name__ == '__main__':
    pass
