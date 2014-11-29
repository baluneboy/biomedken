#!/usr/bin/env python

"""Convert binary files to Audio Interchange File Format (AIFF).

    Given properly-formatted binary data file(s), convert and write the
    information in Audio Interchange File Format (AIFF).

    DISCLAIMER: this project deserves more time than I am able to give and
    probably could benefit from more graceful handling of the unexpected.
"""

import sys
from pims.ugaudio.pad import PadFile
from pims.ugaudio.demo import demo_chirp
from pims.ugaudio.inputs import parse_args, show_args

# Parse input arguments and, if possible, convert to AIFF.
def main():
    """Parse input arguments and, if possible, convert to AIFF."""

    # parse input arguments and show'em
    mode, axis, rate, taper, files = parse_args()
    show_args(mode, axis, rate, taper, files)

    # demo and exit
    if mode == 'demo':
        demo_chirp()
        return 0 # exit code zero for success
    
    # boolean: plot or not
    plot = ( mode == 'plot' )

    # iterate over input file list
    for i, filename in enumerate(files):
        pad_file = PadFile(filename)
        if pad_file.ispad:
            
            try:
                pad_file.convert(rate=rate, axis=axis, plot=plot, taper=taper)
                msg = 'succeeded'
                
             # FIXME if you know how to handle ctrl-c more gracefully
            except KeyboardInterrupt:
                print '\nwe did not finish, but good-bye'
                return 3
            
            # FIXME with better exception handling               
            except:
                msg = 'failed' # just this one file, not total failure
                
        else:
            
            # file must not be properly formatted
            msg = 'not attempted'
            
        # show one-line message for each conversion
        print '%d. %s: conversion %s' % (i + 1, pad_file, msg)
        
    return 0  # exit code zero for success

if __name__ == "__main__":
    sys.exit( main() )
