#!/usr/bin/env python

import sys
import struct
import numpy as np

# Ted Wright's original bin2asc routine was like this...
def ted_write(filename, columns=4):
    """Ted Wright's original bin2asc routine was like this..."""    
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

# return 2d numpy array read from input filename
def array_fromfile(filename, columns=4, out_dtype=np.float32):
    """return 2d numpy array read from input filename"""
    with open(filename, "rb") as f: 
        A = np.fromfile(f, dtype=np.float32) # accel file: 32-bit float "singles"
    B = np.reshape(A, (-1, columns))
    if B.dtype == out_dtype:
        return B
    return B.astype(out_dtype)
