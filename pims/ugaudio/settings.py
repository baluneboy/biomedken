"""
settings
"""

# Author: Ken Hrovat

# Default input parameters:
defaults = {
'samplerate': None, # use None when you have header file or want to dead reckon from data file
'axis':       'z',  # axis to convert; use x, y, z, or s for superposition, which is sum(x+y+z)
'plot':       None, # use None to let program decide when to plot (True to always plot; otherwise False)
}
parameters = defaults.copy()
    
def params_ok(log):
    """Check input parameters."""
    # verify that unique real-time stream is available
    rts = RealtimeStream(parameters['sensor'])
    if not rts.is_unique:
        log.error('Could not identify unique real-time stream for sensor %s.' % parameters['sensor'])
        return False
    
    # verify real-time stream meets frange_hz's upper limit
    rtp = RealtimePlotParameters(plot_type=parameters['plot_type'], frange_hz=parameters['frange_hz'],
        plot_minutes=parameters['plot_minutes'], update_minutes=parameters['update_minutes'])
    if rts.cutoff_hz < rtp.frange_hz[1]:
        log.error('The real-time stream for sensor %s has cutoff (%f Hz) < frange_hz upper limit (%f Hz).' %
                  parameters['sensor'], rts.cutoff_hz, rtp[1])
        return False
        
    # inputs are okay, so log them and continue
    record_inputs(log)
    return True

print parameters