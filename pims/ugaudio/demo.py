#!/usr/bin/env python

import aifc
import numpy as np
import matplotlib.pyplot as plt
from pims.ugaudio.load import array_fromfile
from pims.ugaudio.create import get_chirp
from pims.ugaudio.signal import normalize

def demo_convert_zaxis(filename, fs=500):

    # read data from file
    B = array_fromfile(filename)

    # demean each column
    M = B.mean(axis=0)
    C = B - M[np.newaxis, :]
   
    # just work with z-axis for now
    data = C[:, -1] # z-axis is last column

    # normalize to range -32768:32767 (actually, use -32767:32767)
    #data = normalize(data) * 327670.0
    data = normalize(data) * 32767.0
    
    # data conditioning
    data = data.astype(np.int16) # not sure why we need this...maybe aifc assumptions
    data = data.byteswap().newbyteorder() # need this on mac osx and linux (windows?)

    #plt.plot(data)
    #plt.show()
    
    # convert data to string for aifc to work write
    strdata = data.tostring()
    gn = '/tmp/delombard.aiff'
    print "Writing", gn
    g = aifc.open(gn, 'w')
    sampwidth = 2
    #nchannels, sampwidth, framerate, nframes, comptype, compname
    g.setparams((1, sampwidth, fs, len(data), 'NONE', 'not compressed'))
    g.writeframes(strdata)
    g.close()
    print 'Done'

def demo_chirp(fs=44100):

    # get signal of interest
    y = get_chirp()

    # demean signal
    data = y - y.mean(axis=0)

    # normalize to range -32768:32767 (actually, use -32767:32767)
    data = data * 32767.0
    
    # data conditioning
    data = data.astype(np.int16) # not sure why we need this...maybe aifc assumptions
    data = data.byteswap().newbyteorder() # need this on mac osx and linux (windows?)

    #plt.plot(data)
    #plt.show()
    #raise SystemExit
    
    # convert data to string for aifc to work write
    strdata = data.tostring()
    gn = '/tmp/delombard.aiff'
    print "Writing", gn
    g = aifc.open(gn, 'w')
    sampwidth = 2
    #nchannels, sampwidth, framerate, nframes, comptype, compname
    g.setparams((1, sampwidth, fs, len(data), 'NONE', 'not compressed'))
    g.writeframes(strdata)
    g.close()
    print 'Done'
    
def demo_showparams():
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
    while 1:
        data = f.readframes(1024)
        if not data:
            break
    f.close()
    print "Done."

if __name__ == '__main__':

    #demo_showparams()
    #raise SystemExit

    #fname = '/Users/ken/dev/programs/python/pims/sandbox/data/2014_10_22_09_36_36.324-2014_10_22_09_37_35.317.121f03006'
    #fname = '/home/pims/dev/programs/python/pims/sandbox/data/2014_10_22_09_36_36.324-2014_10_22_09_37_35.317.121f03006'
    #demo_convert_zaxis(fname, fs=142)
    #raise SystemExit
    
    fname = '/misc/yoda/pub/pad/year2014/month10/day22/sams2_accel_121f02/2014_10_22_23_44_02.923+2014_10_22_23_54_02.938.121f02'
    fname = '/home/pims/dev/programs/python/pims/ugaudio/samples/chirp44k.pad'    
    demo_convert_zaxis(fname, fs=11025)    
    raise SystemExit
        
    demo_chirp()
    raise SystemExit