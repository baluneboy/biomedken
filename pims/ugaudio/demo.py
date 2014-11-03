#!/usr/bin/env python

import aifc
import numpy as np
import matplotlib.pyplot as plt
from pims.ugaudio.load import array_fromfile
from pims.ugaudio.create import get_chirp, create_from_aiff
from pims.ugaudio.signal import normalize

def demo_convert_zaxis(filename, fs=500):

    # read data from file
    B = array_fromfile(filename)

    # demean each column
    M = B.mean(axis=0)
    C = B - M[np.newaxis, :]
   
    # just work with z-axis for now
    data = C[:, -1] # z-axis is last column

    # normalize to range -32768:32767 (actually, use -32000:32000)
    data = normalize(data) * 32000.0
    
    # data conditioning
    data = data.astype(np.int16) # not sure why we need this...maybe aifc assumptions
    data = data.byteswap().newbyteorder() # need this on mac osx and linux (windows?)

    #plt.plot(data)
    #plt.show()
    
    # convert data to string for aifc to work write
    strdata = data.tostring()
    gn = '/tmp/delombard.aiff'
    print "writing", gn
    g = aifc.open(gn, 'w')
    sampwidth = 2
    #nchannels, sampwidth, framerate, nframes, comptype, compname
    g.setparams((1, sampwidth, fs, len(data), 'NONE', 'not compressed'))
    g.writeframes(strdata)
    g.close()
    print 'done'

def demo_chirp(fs=44100):

    # get signal of interest
    y = get_chirp()

    # demean signal
    data = y - y.mean(axis=0)

    # normalize to range -32768:32767 (actually, use -32000:32000)
    data = data * 32000.0
    
    # data conditioning
    data = data.astype(np.int16) # not sure why we need this...maybe aifc assumptions
    data = data.byteswap().newbyteorder() # need this on mac osx and linux (windows?)

    #plt.plot(data)
    #plt.show()
    #raise SystemExit
    
    # convert data to string for aifc to work write
    strdata = data.tostring()
    aiff_file = '/tmp/delombard.aiff'
    g = aifc.open(aiff_file, 'w')
    sampwidth = 2
    #nchannels, sampwidth, framerate, nframes, comptype, compname
    g.setparams((1, sampwidth, fs, len(data), 'NONE', 'not compressed'))
    g.writeframes(strdata)
    g.close()
    print 'wrote sound file %s' % aiff_file
    
    # plot data
    png_file = '/tmp/delombard.png'   
    print 'wrote accel plot %s FIXME: NOT YET' % png_file    

#create_from_aiff('/tmp/trash2.aiff'); raise SystemExit

if __name__ == '__main__':

    #demo_showparams()
    #raise SystemExit

    #fname = '/Users/ken/dev/programs/python/pims/sandbox/data/2014_10_22_09_36_36.324-2014_10_22_09_37_35.317.121f03006'
    #fname = '/home/pims/dev/programs/python/pims/sandbox/data/2014_10_22_09_36_36.324-2014_10_22_09_37_35.317.121f03006'
    #demo_convert_zaxis(fname, fs=142)
    #raise SystemExit
    
    fname = '/misc/yoda/pub/pad/year2014/month10/day22/sams2_accel_121f02/2014_10_22_23_44_02.923+2014_10_22_23_54_02.938.121f02'
    fname = '/home/pims/dev/programs/python/pims/ugaudio/samples/test.pad'    
    demo_convert_zaxis(fname, fs=44100)    
    raise SystemExit
        
    demo_chirp()
    raise SystemExit