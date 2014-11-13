#!/usr/bin/env python

import aifc
import numpy as np
import tempfile
import matplotlib.pyplot as plt
from scipy.signal import chirp
from pims.ugaudio.load import aiff_load, array_fromfile

# quick demo to write 4-column PAD file
def demo_write_pad_file(fname):
    """quick demo to write 4-column PAD file"""
    values = [
        [0.0, -1.2,  1.3, -1.4],
        [1.0,  2.2, -2.3,  2.4]
        ]
    a = np.array(values, dtype='float32')
    a.tofile(fname)

# quick demo to read 4-column PAD file   
def demo_write_read_pad_file():
    """quick demo to read 4-column PAD file"""    
    fname = '/tmp/out.bin'
    demo_write_pad_file(fname)
    a = array_fromfile(fname)
    print a

# generate a tapered linear chirp
def get_chirp():
    """generate a tapered linear chirp"""
    t = np.linspace(0, 1, 88200, endpoint=False)
    #print t[0:3], t[1]
    y = chirp(t, f0=20, f1=2000, t1=0.9, method='linear')
    w = np.hanning(len(y))
    return w*y

# write PAD file for chirp (just data file, no header file)
def write_chirp_pad(filename):
    """write PAD file for chirp (just data file, no header file)"""
    wy = get_chirp()
    wy.astype('float32').tofile(filename)

# write rogue PAD file (used for testing, no header file)
def write_rogue_pad_file(filename):
    """write rogue PAD file (used for testing, no header file)"""
    values = [
        [0.0, -1.2,  9.9, -9.9],
        [1.0,  2.2, -9.9,  9.9],
        [2.0, -3.2,  9.9, -9.9],
        [3.0,  4.2, -9.9,  9.9],
        [4.0, -5.2,  9.9, -9.9],
        [5.0,  6.2, -9.9,  9.9],
        [6.0, -7.2,  9.9, -9.9],
        [7.0,  8.2, -9.9,  9.9],
        [8.0, -9.2,  9.9, -9.9],
        ]      
    a = np.array(values, dtype='float32')
    a.tofile(filename)

# FIXME this may not work fully as expected
def aiff2pad(fname):
    pad_file = fname + '.pad'
    y = create_from_aiff(fname)
    print len(y)
    y[0:30264].astype('float32').tofile(pad_file)
    print 'wrote PAD file %s' % pad_file

# FIXME this was just convenient wrapper find/replace create_from_aiff with aiff_load
def create_from_aiff(aiff_file):
    return aiff_load(aiff_file, verbose=True)
