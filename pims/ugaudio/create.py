#!/usr/bin/env python

import numpy as np
from scipy.signal import chirp

# generate a tapered linear chirp
def get_chirp():
    """generate a tapered linear chirp"""
    t = np.linspace(0, 1, 44100)
    y = chirp(t, f0=200, f1=2000, t1=1, method='linear')
    w = np.hanning(len(y))
    return w*y
