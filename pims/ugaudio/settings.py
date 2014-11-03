"""
settings
"""

# Author: Ken Hrovat

# Default input parameters:
defaults = {
'samplerate': None, # sa/sec; use None when you have header file or to let program reckon it from data file
'axis':       'z',  # axis to convert; use x, y, z, or s ( s is superposition, sum(x+y+z) )
'plot':       None, # use None to let program decide when to plot or True to always plot, otherwise False
}
parameters = defaults.copy()
    
# check input parameters
def params_ok():
    """check input parameters"""
    
    # verify sample rate is reasonable
    fs = parameters['samplerate']
    if fs:
        if fs < 0.1 or fs > 44100:
            print 'unexpected sample rate =', fs
            return False
        
    # verify axis
    ax = parameters['axis']
    if not ax in ['x','y','z','s']:
        print 'unexpected axis =', ax
        return False
    
    # verify plot parameter
    plot = parameters['plot']
    if plot:
        if not plot in [None, True, False]:
            print 'unexpected plot parameter =', plot
            return False    
    
    return True
