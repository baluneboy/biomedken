#!/usr/bin/env python

import numpy as np
from blist import sortedlist

def smart_ylims(minval, maxval):
    span = maxval - minval
    ymin = np.ceil( minval - 0.1 * span )
    ymax = np.ceil( maxval + 0.1 * span )
    return (ymin, ymax)

class PlotDataSortedList(sortedlist):
    
    def __init__(self, *args, **kwargs):
        kwargs['key'] = lambda tup: tup[0]
        if kwargs.has_key('maxlen'):
            self.maxlen = int( kwargs.pop('maxlen') )
        else:
            self.maxlen = 999
        super(PlotDataSortedList, self).__init__(*args, **kwargs)

    def _add(self, *args, **kwargs):
        super(PlotDataSortedList, self).add(*args, **kwargs)
            
    def append(self, txyz):
        self._add( txyz )
        while len(self) > self.maxlen:
            toss = self.pop(0)
            print "toss", toss

data = PlotDataSortedList(maxlen=4)

for i in range(11,0,-1):
    data.append( (i, i/10.0) )
    print data
    
data.append( (10.5, 'x') )
data.append( (10.6, 'y') )
print data
    