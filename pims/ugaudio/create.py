#!/usr/bin/env python

import aifc
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import chirp

# generate a tapered linear chirp
def get_chirp():
    """generate a tapered linear chirp"""
    t = np.linspace(0, 1, 44100)
    y = chirp(t, f0=200, f1=2000, t1=1, method='linear')
    w = np.hanning(len(y))
    return w*y

# write PAD file (just data, no header file)
def write_chirp_pad(filename):
    wy = get_chirp()
    wy.astype('float32').tofile(filename)

# FIXME this probably does not work fully as expected
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
    #print y
    #plt.plot(y)
    #plt.show()
    return np.fromstring(data, np.short).byteswap()

aiff2pad('/tmp/trash2.aiff')