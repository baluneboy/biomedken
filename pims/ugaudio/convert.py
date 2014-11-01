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

def convert_zaxis(filename, samplerate):

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
    gn = filename + '.aiff'
    g = aifc.open(gn, 'w')
    sampwidth = 2
    #         nchans, sampwidth, framerate, nframes, comptype, compname
    g.setparams((1, sampwidth, samplerate, len(data), 'NONE', 'not compressed'))
    g.writeframes(strdata)
    g.close()

# convert accel data in filename to audio in filename.aiff; maybe plot too
def convert(filename, plot=False):
    """convert accel data in filename to audio in filename.aiff; if 2nd argument
    is True, then also produce plot of accel data"""

    # use loose interpreation of what a PAD file is here
    pad_file = PadFile(filename)
    if not pad_file.ispad:
        print 'ignore %s' % str(pad_file)
        return
    
    #print pad_file

    aiff_file = filename + '.aiff'
    convert_zaxis(pad_file.filename, pad_file.samplerate)
    print 'wrote sound file %s' % aiff_file
    
    if plot:
        png_file = filename + '.png'
        print 'wrote accel plot %s' % png_file
