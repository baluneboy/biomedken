#!/usr/bin/env python

import sys
import aifc
import struct
import numpy as np

# return 2d numpy array read from input filename
def array_fromfile(filename, columns=4):
    """return 2d numpy array read from input filename"""
    with open(filename, "rb") as f: 
        A = np.fromfile(f, dtype=np.float32)
    B = np.reshape(A, (-1, columns))
    return B

# Ted Wright original bin2asc routine
def ted_write(filename, columns=4):
    """Ted Wright original bin2asc routine"""    
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

def demo_convert_zaxis(filename, columns=4):
    with open(filename, "rb") as f: 
        A = np.fromfile(f, dtype=np.float32)
    B = np.reshape(A, (-1, columns))
    M = B.mean(axis=0)
    C = B - M[np.newaxis, :]    
    data = C[:, -1] # Z-axis is last axis
    gn = '/tmp/delombard.aiff'
    print "Writing", gn
    g = aifc.open(gn, 'w')
    sampwidth = 4
    #nchannels, sampwidth, framerate, nframes, comptype, compname
    g.setparams((1, sampwidth, 500, len(data), 'NONE', 'not compressed'))
    g.writeframes(data)
    g.close()
    print 'Done'
    
def demo2():
    fn = '/tmp/GlassLoud.aiff'
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
    
    fname = '/Users/ken/Downloads/2014_10_17_06_54_14.883-2014_10_17_06_54_44.573.121f03006'
    
    demo_convert_zaxis(fname)
    
    #a = array_fromfile(fname)
    #print a
    
    #demo2()