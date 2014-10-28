#!/usr/bin/env python

import sys
import aifc
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
        A = np.fromfile(f, dtype=np.float32) # file is 32-bit float "singles"
    B = np.reshape(A, (-1, columns))
    if B.dtype == out_dtype:
        return B
    return B.astype(out_dtype)

def demo_convert_zaxis(filename):
    B = array_fromfile(filename)
    M = B.mean(axis=0)
    C = B - M[np.newaxis, :]    
    data = C[:, -1] # Z-axis is last axis
    strdata = data.tostring()
    print len(data)
    print len(strdata)
    gn = '/tmp/delombard.aiff'
    print "Writing", gn
    g = aifc.open(gn, 'w')
    sampwidth = 4
    #nchannels, sampwidth, framerate, nframes, comptype, compname
    g.setparams((1, sampwidth, 142, len(data), 'NONE', 'not compressed'))
    g.writeframes(strdata)
    g.close()
    print 'Done'
    
def demo2():
    fn = '/home/pims/Music/bzz.aiff'
    f = aifc.open(fn, 'r')
    print "Reading", fn
    print "nchannels =", f.getnchannels()   # 1 is mono: x, y, z, or sum [all after demean]
    print "nframes   =", f.getnframes()     # nframes is number of rows in np array
    print "sampwidth =", f.getsampwidth()   # use 4 (not 2)
    print "framerate =", f.getframerate()   # sample rate, fs = 500 for fc = 200 Hz
    print "comptype  =", f.getcomptype()    # 'NONE'
    print "compname  =", f.getcompname()    # 'not compressed'
    print f.getparams()
    #gn = '/tmp/GlassLoud_out.aiff'
    #print "Writing", gn
    #g = aifc.open(gn, 'w')
    ## setparams(nchannels, sampwidth, framerate, nframes, comptype, compname)
    ## setparams(1, 2, 44100, 132300, 'NONE', 'not compressed')
    #g.setparams(f.getparams())
    while 1:
        data = f.readframes(1024)
        if not data:
            break
    #    g.writeframes(data)
    #g.close()
    f.close()
    print "Done."

if __name__ == '__main__':
    
    fname = '/home/pims/dev/programs/python/pims/sandbox/data/2014_10_22_09_36_36.324-2014_10_22_09_37_35.317.121f03006'
    
    #demo_convert_zaxis(fname)
    
    a = array_fromfile(fname, columns=4, out_dtype=np.float32)
    
    m = a.mean(axis=0)
    z = a[:, -1] # z-axis is last axis
    print np.mean(z)
    c = a - m[np.newaxis, :]    
    z = c[:, -1] # z-axis is last axis
    print np.mean(z)
    print z[0:9]
    
    
    #demo2()