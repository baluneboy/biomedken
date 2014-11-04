#!/usr/bin/env python

"""
For some important considerations and disclaimers, see the readme.txt file.

This program attempts to convert PIMS acceleration data (PAD) files into AIFF
audio files, and possibly plot the demeaned acceleration data too (see below).

Given zero input arguments, this program shows this help text and quits.

Given multiple input arguments, this program attempts to read each as an
acceleration (PAD) data file named <filename> and convert its contents to an
AIFF audio file with suffix "s.aiff"; where s designates sum(x+y+z) axis data.

Given the input argument "demo" [no quotes], this program generates its own
(fake) acceleration (PAD) data and treats that as it would given one input
argument, which is described below.

Given one input argument, this program takes that as an acceleration (PAD) data
file named <filename> and does the following with its contents:
(1) produce 4 plots of the demeaned acceleration data:
    1. <filenamex.png> for X-axis
    2. <filenamey.png> for Y-axis
    3. <filenamez.png> for Z-axis
    4. <filenames.png> for sum(x+y+z)
(2) write 4 AIFF audio files named similar to the PNG plot files above except with
    the extension "aiff" instead of "png"
    
EXAMPLES:

# run simple demo
python ugaudio.py -m demo

# convert a PAD file to AIFF
python ugaudio.py filename

# convert a PAD file to AIFF and produce PNG for accel plot too
python ugaudio.py -m plot filename

# convert PAD files to AIFFs; use rate of 22050 sa/sec, & produce PNGs for accel plots
python ugaudio.py -m plot -r 22050 filename1 filename2

INPUT ARGUMENTS:
"""

# Author: Ken Hrovat
# Disclaimer: this project deserves more time than I am able to give it
# FIXME - this code should be much more graceful in handling the unexpected

import sys
import argparse

# /misc/yoda/pub/pad/year2014/month10/day09/sams2_accel_121f04/2014_10_09_13_32_23.772+2014_10_09_13_34_02.623.121f04

# class to override argparse error message
class MyParser(argparse.ArgumentParser):
    """class to override argparse error message"""
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)
#    print 'const_collection =', results.const_collection

# parse input arguments
def parse_args():
    parser = MyParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-m', default="aiff", choices=['aiff', 'plot', 'demo'], help="which mode to use")
    parser.add_argument('-r', type=int, default=0, help="integer > 0 for sample rate to override default")
    parser.add_argument('files', nargs='*', help="file(s) to process")
    args = parser.parse_args()
    
    # no input args, so just print help
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)    

    # turn arg switches into vars
    mode = args.m
    rate = args.r
    files = args.files
    
    # courtesy output
    if not mode == 'demo':
        print "mode = %s," % mode,
        if rate:
            print "sample rate = {} sa/sec,".format(rate),
        else:
            print "sample rate = native,",
        print "file count = %d" % len(files)
    else:
        print "mode = %s" % mode

    return mode, rate, files
