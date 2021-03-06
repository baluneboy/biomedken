#!/usr/bin/env python

import aifc
import numpy as np
import tempfile
import matplotlib.pyplot as plt
from scipy.signal import chirp
from pims.ugaudio.load import aiffread, padread

# A class to implement a "signal" with alternating integers.
class AlternateIntegers(object):
    """A class to implement a "signal" with alternating integers.

    This class will produce an array ("signal") of length numpts with
    alternating integers: +value, -value, +value,... This is convenient for test
    purposes.
    
    """
    
    def __init__(self, value=9, numpts=5):
        """Constructor."""
        self.value = value
        self.numpts = numpts
        self.signal = self.alternate_integers()
        # get approx midpoint index
        idxmid = numpts // 2
        if numpts % 2 == 0:
            self.idx_midpts = [idxmid-1, idxmid]
        else:
            self.idx_midpts = [idxmid]

    # Return numpts alternate integers: +x, -x, etc.
    def alternate_integers(self):
        """Return numpts alternate integers: +x, -x, etc."""
        x = np.empty((self.numpts,), int)
        x[::2]  = +self.value
        x[1::2] = -self.value
        return x
    
    # Write data to AIFF file, fname.
    def aiffwrite(self, fname, fs=22050):
        """Write data to AIFF file, fname."""
        # normalize to range +/-32000
        data = self.signal / self.value
        data = data * 32000.0
        
        # data conditioning
        data = data.astype(np.int16) # not sure why we need this...maybe aifc assumptions
        data = data.byteswap().newbyteorder() # need this on mac osx and linux (windows?)
        
        # convert data to string for aifc to work write
        strdata = data.tostring()
        g = aifc.open(fname, 'w')
        sampwidth = 2
        #nchannels, sampwidth, framerate, nframes, comptype, compname
        g.setparams((1, sampwidth, fs, len(data), 'NONE', 'not compressed'))
        g.writeframes(strdata)
        g.close()

# Write binary (PAD-like) file.
def padwrite(x, y, z, fs, fname, return_time=False):
    """Write binary (PAD-like) file."""
    N = float(len(x))
    T = float(N/fs)
    t = np.linspace(0, T, N, endpoint=False)
    data = np.c_[ t, x, y, z ]
    data.astype('float32').tofile(fname)
    if return_time:
        return t

# Write PAD file for chirp (just data file, no header file).
def write_chirp_pad(filename):
    """Write PAD file for chirp (just data file, no header file)."""
    # just one column (like x-axis) gets written (no y-, or z-axis)
    wy = get_chirp()
    wy.astype('float32').tofile(filename)
    
# Write rogue PAD file (used for testing, no header file).
def write_rogue_pad_file(filename):
    """Write rogue PAD file (used for testing, no header file)."""
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

# Generate a tapered linear chirp signal.
def get_chirp():
    """Generate a tapered linear chirp signal."""
    t = np.linspace(0, 1, 88200, endpoint=False)
    #print t[0:3], t[1]
    y = chirp(t, f0=20, f1=2000, t1=0.9, method='linear')
    w = np.hanning(len(y))
    return w*y

# Convert uncompressed AIFF file to PAD formatted file.
def uncompressed_aiff2pad(fname):
    """Convert uncompressed AIFF file to PAD formatted file.
    For the PAD output file:
    - t comes from length of signal and sample rate
    - x is the signal as-is
    - y is half amplitude negated signal
    - z is same as y
    """   
    # name for output PAD file
    pad_file = fname + '.pad'
    
    # load data from AIFF file
    x, params = aiffread(fname)
    fs = params[2] # sample rate
    
    # Create y-axis data
    y = -0.5 * x
    padwrite(x, y, y, fs, pad_file) # NOTE: z = y

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
    a = padread(fname)
    print a

# generate representative scenario 1
def scenario1():
    """generate a linear chirp with representative ranges
    for amplitude and frequency; representative of "loud" International Space
    Station vibratory microgravity environment, we should expect a portion of
    that signal (below 20 Hz and perhaps even a bit higher than that) to be
    inaudible; my ears filter with pass-band starting at about 40 Hz or, my
    speakers did not reproduce good bass -- it's all about that bass
    """
    t = np.linspace(0, 20, 11025*20, endpoint=False)
    x = 1e-6*chirp(t, f0=0.1, f1=200, t1=19.5, method='linear')
    y = 5e-4*chirp(t, f0=0.1, f1=200, t1=19.5, method='linear')
    z = 1e-3*chirp(t, f0=0.1, f1=200, t1=19.5, method='linear')
    fname = '/Users/ken/dev/programs/python/pims/ugaudio/samples/scenario1.pad'
    padwrite(x, y, z, 11025, fname)

#scenario1()