#!/usr/bin/env python

import numpy as np

def smart_ylims(minval, maxval):
    span = maxval - minval
    ymin = np.ceil( minval - 0.1 * span )
    ymax = np.ceil( maxval + 0.1 * span )
    return (ymin, ymax)
