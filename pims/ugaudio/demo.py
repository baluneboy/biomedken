#!/usr/bin/env python

import aifc
import numpy as np
import matplotlib.pyplot as plt
from pims.ugaudio.load import array_fromfile
from pims.ugaudio.create import get_chirp
from pims.ugaudio.signal import normalize

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
    plt.plot(data)
    plt.savefig(png_file)    
    print 'wrote accel plot %s' % png_file    
