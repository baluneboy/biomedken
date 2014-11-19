#!/usr/bin/env python

import aifc
import numpy as np
import tempfile
import matplotlib.pyplot as plt
from scipy.signal import chirp
from pims.ugaudio.load import aiff_load, array_fromfile

# A class to implement a "signal" with alternating integers.
class AlternateIntegers(object):
    """A class to implement a "signal" with alternating integers.

    This class will produce an array ("signal") of length numpts with
    alternating integers: +value, -value, +value,... This is convenient for test
    purposes.
    
    """
    
    def __init__(self, value=9, numpts=5):
        """Constructs an AlternateIntegers object."""
        self.value = value
        self.numpts = numpts
        self.signal = self.alternate_integers()
        # get approx midpoint index
        idxmid = numpts // 2
        if numpts % 2 == 0:
            self.idx_midpts = [idxmid-1, idxmid]
        else:
            self.idx_midpts = [idxmid]

    # Return alternating integers with postive and negative values (first is positive).
    def alternate_integers(self):
        """Fill alternates with postive and negative values (first is positive)."""
        x = np.empty((self.numpts,), int)
        x[::2]  = +self.value
        x[1::2] = -self.value
        return x

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

# FIXME this does not work fully as expected (what about t, x, and z)
def aiff2pad(fname):
    pad_file = fname + '.pad'
    y = aiff_load(fname)
    print len(y)
    y[0:30264].astype('float32').tofile(pad_file)
    print 'wrote PAD file %s' % pad_file

def scenario1():
    """
    generate a linear chirp with amplitude and frequency ranges that are
    representative of the loudest International Space Station's vibratory
    microgravity environment, we should expect a portion of that signal (below
    20 Hz and perhaps even a bit higher than that) to be inaudible; one
    world-renowned microgravity data analyst I know either has high-pass
    filtering ears with a pass-band starting at about 40 Hz or, the poor guy
    used speakers that did not reproduce good bass -- it's all about that bass
    """
    t = np.linspace(0, 20, 11025*20, endpoint=False)
    x = 1e-6*chirp(t, f0=0.1, f1=200, t1=19.5, method='linear')
    y = 5e-4*chirp(t, f0=0.1, f1=200, t1=19.5, method='linear')
    z = 1e-3*chirp(t, f0=0.1, f1=200, t1=19.5, method='linear')
    data = np.c_[ t, x, y, z ]
    data.astype('float32').tofile('/Users/ken/dev/programs/python/pims/ugaudio/samples/scenario1.pad')
    print 'done'

#scenario1()