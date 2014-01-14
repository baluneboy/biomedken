#!/usr/bin/python

class IntervalStat(object):
    """istat = IntervalStat(analysis_interval)

    This class supports interval statistic calculations (like RMS).
    """

    def __init__ (self, analysis_interval):
        self.analysis_interval = analysis_interval

    def __repr__(self):
        return "%g-Second %s" % (self.analysis_interval, self.__class__.__name__)
   
    def get_result(self, obj, meth):
        raise NotImplementedError('it is subclass responsibility to implement get_result method')

class IntervalRMS(IntervalStat):
    def get_result(self, obj, meth):
        print obj.get_span()
        method_to_call = getattr(obj, meth)
        result = method_to_call()
        return result 

class PadProcessChain(object):
    """Scale, Demean, 5 Hz Lowpass, 10-Second Interval RMS, Per-Axis"""

    def __init__(self,
                 scale_factor=1e6,
                 detrend_type='demean',
                 filter_params={'type':'lowpass', 'freq':5, 'zerophase':True},
                 interval_params={'type':IntervalRMS, 'analysis_interval':10},
                 axes=['x','y','z']):
        self.scale_factor = scale_factor
        self.units = self._get_units()
        self.detrend_type = detrend_type
        self.filter_params = filter_params
        self.interval_func = interval_params['type'](interval_params['analysis_interval'])
        self.axes = axes

    def _get_units(self):
        if self.scale_factor == 1e3:
            return 'mg'
        elif self.scale_factor == 1e6:
            return 'ug'
        else:
            raise ValueError('unexpected scale factor of %g (try 1e3 or 1e6)' % self.scale_factor)

    def __repr__(self):
        return "%s:\n(1) scale_factor=%g (%s)\n(2) detrend_type='%s'\n(3) filter_params=%s\n(4) interval_func='%s'\n(5) axes=%s" % \
            (self.__class__.__name__,
             self.scale_factor, self.units,
             self.detrend_type,
             str(self.filter_params),
             str(self.interval_func),
             str(self.axes))

if __name__=="__main__":
    from obspy import read
    from pims.pad.padstream import PadStream
    
    ppc = PadProcessChain()
    print ppc
    
    irms = IntervalRMS(10)
    st = read()
    result = irms.get_result(st, 'std')
    print result
    
