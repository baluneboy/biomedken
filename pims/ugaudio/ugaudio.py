#!/usr/bin/env python

# Author: Ken Hrovat
# Disclaimer: this project deserves more time than I am able to give it
# FIXME - this code should be much more graceful in handling the unexpected

import sys
from pims.ugaudio.demo import demo_chirp
from pims.ugaudio.pad import PadFile
from pims.ugaudio.inputs import parse_args

# /misc/yoda/pub/pad/year2014/month10/day09/sams2_accel_121f04/2014_10_09_13_32_23.772+2014_10_09_13_34_02.623.121f04
    
# get inputs and run
def main():
    """get inputs and run"""

    # parse input arguments
    mode, rate, files = parse_args()

    # demo
    if mode == 'demo':
        demo_chirp()

    # loop over file(s)
    elif len(files) > 0:
        for filename in sys.argv[1:]:
            pad_file = PadFile(filename)
            #convert(filename, samplerate=None, axis='xyzs', plot=True)
            #convert(filename)
            print pad_file
            
    else:
        print 'could not determine what to do from inputs'

    sys.exit(0)

if __name__ == "__main__":
    main()
