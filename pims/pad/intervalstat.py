#!/usr/bin/python

class PadProcessChain(object):
    """Demean, 5 Hz Lowpass, 10-Second Interval RMS, Per-Axis"""
    
    def __init__(self,
                 detrend_type='demean',
                 filter_params={'type':'lowpass', 'freq':5, 'zerophase':True},
                 axes=['x','y','z']):
        self.detrend_type = detrend_type
        self.filter_params = filter_params
        self.axes = axes
    
    def __repr__(self):
        plot_span_minutes = self.plot_span / 60.0
        return "%g-Second %s, %g-minute plot, units of %s" % (self.analysis_interval,
                                                         self.__class__.__name__,
                                                         plot_span_minutes,
                                                         self.units)

class IntervalStat(object):
    """istat = IntervalStat(analysis_interval, plot_span, scale_factor)

    This class supports interval statistics calculations.
    """
    
    def __init__ (self, analysis_interval, plot_span, scale_factor, filt):
        self.analysis_interval = analysis_interval
        self.plot_span = plot_span
        self.scale_factor = scale_factor
        self.units = self._get_units()
        self.filter = filt

    def _get_units(self):
        if self.scale_factor == 1e3:
            return 'mg'
        elif self.scale_factor == 1e6:
            return 'ug'
        else:
            raise ValueError('unexpected scale factor of %g (try 1e3 or 1e6)' % self.scale_factor) 

    def __repr__(self):
        plot_span_minutes = self.plot_span / 60.0
        return "%g-Second %s, %g-minute plot, units of %s" % (self.analysis_interval,
                                                         self.__class__.__name__,
                                                         plot_span_minutes,
                                                         self.units)

class IntervalRMS(IntervalStat): pass
    
if __name__=="__main__":
    filt = ('lowpass', {'freq':5.0, 'zerophase':True})
    istat = IntervalRMS(10, 600, 1e6, filt)
    print istat
    print istat.filter[0], istat.filter[1]
