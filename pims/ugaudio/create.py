#!/usr/bin/env python

import aifc
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import chirp

# just a quick dirty demo to write pad file (FIXME)
def demo_write_pad_file():
    from pims.ugaudio.load import array_fromfile
    values = [ [0.0, -1.2, 1.3, -1.4], [1.0, 2.2, -2.3, 2.4] ]
    a = np.array(values, dtype='float32')
    a.tofile('/tmp/out.bin')
    b = array_fromfile('/tmp/out.bin')
    print b

# generate a tapered linear chirp
def get_chirp():
    """generate a tapered linear chirp"""
    t = np.linspace(0, 1, 88200)
    y = chirp(t, f0=20, f1=2000, t1=0.9, method='linear')
    w = np.hanning(len(y))
    return w*y

# write PAD file (just data file, no header file)
def write_chirp_pad(filename):
    wy = get_chirp()
    wy.astype('float32').tofile(filename)

# FIXME this may not work fully as expected
def aiff2pad(fname):
    pad_file = fname + '.pad'
    y = create_from_aiff(fname)
    print len(y)
    y[0:30264].astype('float32').tofile(pad_file)
    print 'wrote PAD file %s' % pad_file

def create_from_aiff(aiff_file):
    f = aifc.open(aiff_file, 'r')
    print "Reading", aiff_file
    print "nchannels =", f.getnchannels()   # 1 is mono: x, y, z, or sum [all after demean]
    print "nframes   =", f.getnframes()     # nframes is number of rows in np array
    print "sampwidth =", f.getsampwidth()   # use 4 (not 2)
    print "framerate =", f.getframerate()   # sample rate, fs = 500 for fc = 200 Hz
    print "comptype  =", f.getcomptype()    # 'NONE'
    print "compname  =", f.getcompname()    # 'not compressed'
    print f.getparams()
    data = ''
    while True:
        newdata = f.readframes(512)
        if not newdata:
            break
        data += newdata
    f.close()
    return np.fromstring(data, np.short).byteswap()

#aiff2pad('/tmp/trash2.aiff')

#write_chirp_pad('/tmp/chirp.pad')