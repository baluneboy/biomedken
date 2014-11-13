#!/usr/bin/env python

"""
For important considerations and disclaimers, see the readme.txt file.

This program attempts to convert PIMS acceleration data (PAD) files into AIFF
audio files, and it can plot the demeaned acceleration data too.

Given zero input arguments, this program shows this help text and quits.

Given multiple input filename arguments, this program attempts to read each as
an acceleration (PAD) data file named <filename> and convert its contents to an
AIFF audio file with suffix "s.aiff"; where s designates sum(x+y+z) axis data.
You can change the default behavior with input argument options for mode, axis,
rate, taper.

Conversion filenames: given a valid PAD file named <filename> with plot mode
selected, this program produces a plot of the demeaned acceleration data for the
axis selected, e.g. <filenamex.png> for X-axis. Also, it always attempts to
write an AIFF audio file named similar to the PNG plot files above except with
the extension "aiff" instead of "png".
    
EXAMPLES:

# to run simple demo
python ugaudio.py -m demo

# to convert a PAD file to AIFF
python ugaudio.py filename

# to convert a PAD file to AIFF and produce PNG for demeaned accel plot too
python ugaudio.py -m plot filename

# to convert PAD files to AIFFs using new rate of 22050 sa/sec & produce PNGs for accel plots
python ugaudio.py -m plot -r 22050 filename1 filename2

INPUT ARGUMENTS (see "usage" on first line above):
"""

# Author: Ken Hrovat
# Disclaimer: this project deserves more time than I am able to give it
# FIXME - this code should be much more graceful in handling the unexpected

import sys
import argparse

# /misc/yoda/pub/pad/year2014/month10/day09/sams2_accel_121f04/2014_10_09_13_32_23.772+2014_10_09_13_34_02.623.121f04

# check for non-negative value
def check_nonnegative(value):
    """check for non-negative value"""
    ivalue = int(value)
    if ivalue < 0:
         raise argparse.ArgumentTypeError("%s is an invalid non-negative int value" % value)
    return ivalue

# class to override argparse error message
class MyParser(argparse.ArgumentParser):
    """class to override argparse error message"""
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(1)

# courtesy echo arguments
def show_args(mode, axis, rate, taper, files):
    """courtesy echo arguments"""
    if not mode == 'demo':
        print "mode = %s," % mode,
        if rate:
            print "sample rate = {} sa/sec,".format(rate),
        else:
            print "sample rate = native,",
        print "axis = %s," % axis,
        print "taper = %sms," % str(taper),
        print "file argument count = %d" % len(files)
        if len(files) == 0:
            print "It looks like you neglected to include file(s) as command line arguments."
            print "No PAD-like file argument(s), so nothing to do.  Try no arguments for help."
            print "Bye for now."
            sys.exit(3)
    else:
        print "mode = %s" % mode
    
    print '~' * 80

# parse input arguments
def parse_args():
    parser = MyParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-m', default="aiff", choices=['aiff', 'plot', 'demo'], help="mode choice")
    parser.add_argument('-a', default="s", choices=['x', 'y', 'z', 's', '4'], help="axis; default is s (for sum), use 4 to do all")
    parser.add_argument('-r', default=0, type=check_nonnegative, help="integer R > 0 for sample rate to override native; default R=0 for native rate")
    parser.add_argument('-t', default=0, type=check_nonnegative, help="integer T > 0 for milliseconds of taper; default T=0 for no tapering")
    parser.add_argument('files', nargs='*', help="file(s) to process")
    args = parser.parse_args()
    
    # no input args, so just print help
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(2)

    # return arguments: (m)ode, (a)xis, (r)ate, (t)aper, and files
    return args.m, args.a, args.r, args.t, args.files