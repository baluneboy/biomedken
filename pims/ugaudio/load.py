#!/usr/bin/env python

import sys
import aifc
import struct
import numpy as np

# Ted Wright's original bin2asc routine convert file to ASCII.
def ted_write(filename, columns=4):
    """Ted Wright's original bin2asc routine convert file to ASCII."""    
    f = open(filename)
    d = f.read()
    f.close()
    sys.stdout = open(filename+'.ascii', 'w')
    for i in range(len(d)/4):
        v = struct.unpack('<f', d[i*4:i*4+4]) # force little Endian float
        print '% 12.9e   ' % v,
        if i%columns == columns-1:
            print
    sys.stdout.close()

# Return 2d numpy array read from filename input.
def array_fromfile(filename, columns=4, out_dtype=np.float32):
    """Return 2d numpy array read from filename input."""
    with open(filename, "rb") as f: 
        A = np.fromfile(f, dtype=np.float32) # accel file: 32-bit float "singles"
    B = np.reshape(A, (-1, columns))
    if B.dtype == out_dtype:
        return B
    return B.astype(out_dtype)

# Return array loaded from aiff file.
def aiff_load(aiff_file, verbose=False):
    """Return array loaded from aiff file."""
    f = aifc.open(aiff_file, 'r')
    if verbose:
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