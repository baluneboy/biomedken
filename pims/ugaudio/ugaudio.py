#!/usr/bin/env python

# Author: Ken Hrovat
# Disclaimer: this project deserves more time than I am able to give it
# FIXME - this code should be much more graceful in handling the unexpected

import sys
from pims.ugaudio.demo import demo_chirp
from pims.ugaudio.pad import PadFile
from pims.ugaudio.inputs import parse_args, show_args

# /misc/yoda/pub/pad/year2014/month10/day09/sams2_accel_121f04/2014_10_09_13_32_23.772+2014_10_09_13_34_02.623.121f04
    
# get inputs and run
def main():
    """get inputs and run"""

    # parse input arguments
    mode, axis, rate, files = parse_args()
    show_args(mode, axis, rate, files)

    # demo and exit
    if mode == 'demo':
        demo_chirp()
        sys.exit(0)
    
    # do we need plots or not
    plot = ( mode == 'plot' )

    # loop over file(s)
    for i, filename in enumerate(files):
        pad_file = PadFile(filename)
        if pad_file.ispad:
            try:
                pad_file.convert(rate=rate, axis=axis, plot=plot)
                msg = 'succeeded'
            except Exception, e:
                msg = 'failed'
        else:
            msg = 'not attempted'
        print 'file arg %d %s: conversion %s' % (i + 1, pad_file, msg)

    sys.exit(0)

if __name__ == "__main__":
    main()
