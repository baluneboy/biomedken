#!/usr/bin/env python

"""
This module does conversion from acceleration data file to AIFF audio file.
Optionally, it produces acceleration data plot in PNG file too.
"""

# Author: Ken Hrovat
# Disclaimer: this code can probably be improved in many ways

import sys
import aifc
import numpy as np
from pims.ugaudio.pad import PadFile
from pims.ugaudio.load import array_fromfile
from pims.ugaudio.signal import normalize
import matplotlib.pyplot as plt

# convert designated axis of input file to aiff
def convert(filename, samplerate=None, axis='z', plot=False):
    """convert designated axis of input file to aiff"""

    # use loose interpreation of what a PAD file is here
    pad_file = PadFile(filename)
    if not pad_file.ispad:
        print 'ignore %s' % str(pad_file)
        return

    #print pad_file
    
    if not samplerate:
        samplerate = pad_file.samplerate

    if not isinstance(samplerate, float):
        print 'ignore bad sample rate for %s' % str(pad_file)
        return
    
    # read data from file
    B = array_fromfile(filename)

    # demean each column
    M = B.mean(axis=0)
    C = B - M[np.newaxis, :]

    # FIXME how to use numpy when axis is 's' for 'sum'
    
    # determine axis
    ax = axis.lower()
    if ax == 'x':   data = C[:, -3] # x-axis is 3rd last column
    elif ax == 'y': data = C[:, -2] # y-axis is 2nd last column
    elif ax == 'z': data = C[:, -1] # z-axis is the last column
    elif ax == 's': data = C[:, 1::].sum(axis=1) # sum(x+y+z)
    else:
        print 'unhandled axis "%s", so just use z-axis' % axis
        ax = 'z'
        data = C[:, -1] # just use z-axis in this case

    # plot demeaned accel data (if plot is to be produced)
    if plot:
        png_file = filename + ax + '.png'
        plt.plot(data)
        plt.savefig(png_file)
        print 'wrote accel plot %s' % png_file
        
    # normalize to range -32768:32767 (actually, use -32000:32000)
    data = normalize(data) * 32000.0

    # data conditioning
    data = data.astype(np.int16) # not sure why we need this...maybe aifc assumptions
    data = data.byteswap().newbyteorder() # need this on mac osx and linux (windows?)

    # convert data to string for aifc to work write
    strdata = data.tostring()
    aiff_file = filename + ax + '.aiff'
    g = aifc.open(aiff_file, 'w')
    sampwidth = 2
    #         nchans, sampwidth, framerate, nframes, comptype, compname
    g.setparams((1, sampwidth, samplerate, len(data), 'NONE', 'not compressed'))
    g.writeframes(strdata)
    g.close()
    print 'wrote sound file %s' % aiff_file
