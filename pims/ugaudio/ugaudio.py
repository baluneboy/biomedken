#!/usr/bin/env python

"""
USAGE: ugaudio [ demo | <filename> | <filenames> ]

SEE the readme.txt file for important considerations and disclaimers.

This simple program attempts to convert acceleration data files (PAD files) into
AIFF audio files.

Given zero input arguments, this program shows this help text and quits.

Given multiple input arguments, this program attempts to read each as an
acceleration (PAD) data file named <filename> and convert its contents to an
AIFF audio file named <filename.aiff>.

Given the input argument "demo" [no quotes], this program generates its own
(fake) acceleration (PAD) data and treats that as it would given one input
argument, which is described below.

Given one input argument, this program takes that as an acceleration (PAD) data
file named <filename> and does the following with its contents:
(1) produce plot of the demeaned acceleration data
(2) write AIFF audio file named <filename.aiff>

User settings are in settings.py. You should probably SAVE THE ORIGINAL VERSION
of the settings.py file in case something gets messed up.
"""

# Author: Ken Hrovat
# Disclaimer: this project deserves more time than I am able to give it
# FIXME - this code should be much more graceful in handling the unexpected

import sys
from pims.ugaudio.load import is_pad
from pims.ugaudio.demo import demo_chirp
from pims.ugaudio.convert import convert

# get inputs and run
def main():
    """get inputs and run"""
    
    # no input args, so just show doc
    if not sys.argv[1:]:
        print __doc__
    
    # demo
    elif sys.argv[1].lower() == 'demo':
        print 'demo mode'
        demo_chirp()
    
    # one file mode: both sound and plot file outputs for input file
    elif len(sys.argv) == 2:
        print 'one file mode'
        filename = sys.argv[1]    
        convert(filename, plot=True)
    
    # batch files mode: only sound file output for each input file
    else:
        print 'batch files mode'
        for filename in sys.argv[1:]:
            if is_pad(filename):
                convert(filename, plot=False)
            else:
                print 'ignore non-pad file %s' % filename
        
    sys.exit(0)

if __name__ == "__main__":
    main()
