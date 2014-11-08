#!/usr/bin/env python

# Author: Ken Hrovat
# Disclaimer: this project deserves more time than I am able to give it
# FIXME - this package should be much more graceful in handling the unexpected

import sys
from pims.ugaudio.demo import demo_chirp
from pims.ugaudio.pad import PadFile
from pims.ugaudio.inputs import parse_args, show_args

# get inputs and run
def main():
    """get inputs and run"""

    # parse input arguments
    mode, axis, rate, taper, files = parse_args()
    show_args(mode, axis, rate, taper, files)

    # demo and exit
    if mode == 'demo':
        demo_chirp()
        sys.exit(0)
    
    # boolean, do we need plots or not
    plot = ( mode == 'plot' )

    # loop over file(s)
    for i, filename in enumerate(files):
        pad_file = PadFile(filename)
        if pad_file.ispad:
            try:
                pad_file.convert(rate=rate, axis=axis, plot=plot, taper=taper)
                msg = 'succeeded'
            except Exception, e:
                raise Exception(e)
                msg = 'failed'
        else:
            msg = 'not attempted'

        # show one-liner for each conversion (succeeded, failed or not attempted)
        print '%d. %s: conversion %s' % (i + 1, pad_file, msg)

    sys.exit(0)

if __name__ == "__main__":
    main()
