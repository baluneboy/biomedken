#!/usr/bin/env python

"""
This module does conversion from acceleration data file to AIFF audio file.
Optionally, it produces acceleration data plot in PNG file too.
"""

# Author: Ken Hrovat

import sys

# convert accel data in filename to audio in filename.aiff; maybe plot too
def convert(filename, plot=False):
    """convert accel data in filename to audio in filename.aiff; if plot arg
    True, then also produce plot of accel data"""
    
    aiff_file = filename + '.aiff'

    if plot:
        png_file = filename + '.png'
        print 'converted & saved %s' % aiff_file
        print 'plotted accel. in %s' % png_file
    else:
        print 'converted & saved %s' % aiff_file
