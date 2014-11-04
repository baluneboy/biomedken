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
"""

# Author: Ken Hrovat
# Disclaimer: this project deserves more time than I am able to give it
# FIXME - this code should be much more graceful in handling the unexpected

import sys
import argparse
from pims.ugaudio.pad import PadFile
#from pims.ugaudio.demo import demo_chirp
#from pims.ugaudio.convert import convert

# /misc/yoda/pub/pad/year2014/month10/day09/sams2_accel_121f04/2014_10_09_13_32_23.772+2014_10_09_13_34_02.623.121f04

# class to override argparse error message
class MyParser(argparse.ArgumentParser):
    """class to override argparse error message"""
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

# parse input arguments
def OLDparse_args():
    """parse input arguments"""

    parser = MyParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    subparsers = parser.add_subparsers(help='commands')

    # a demo command
    demo_parser = subparsers.add_parser('demo', help='Demo')
    demo_parser.add_argument('demo_name', action='store', help='Which demo to do {chirp,voice}')

    # a list command
    list_parser = subparsers.add_parser('list', help='List contents')
    list_parser.add_argument('dirname', action='store', help='Directory to list')

    # a create command
    create_parser = subparsers.add_parser('create', help='Create a directory')
    create_parser.add_argument('dirname', action='store', help='New directory to create')
    create_parser.add_argument('--read-only', default=False, action='store_true',
                               help='Set permissions to prevent writing to the directory',
                               )

    # a delete command
    delete_parser = subparsers.add_parser('delete', help='Remove a directory')
    delete_parser.add_argument('dirname', action='store', help='The directory to remove')
    delete_parser.add_argument('--recursive', '-r', default=False, action='store_true',
                               help='Remove the contents of the directory, too',
                               )

    # no input args, so just show doc help
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    args = vars( parser.parse_args() )
    return args

def TOOparse_args():
    parser = MyParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    
    parser.add_argument('-s', action='store', dest='simple_value',
                        help='Store a simple value')
    
    parser.add_argument('-c', action='store_const', dest='constant_value',
                        const='value-to-store',
                        help='Store a constant value')

    parser.add_argument('-d', action='store_true', default=False,
                        dest='demo_switch',
                        help='Set demo switch to true')
    
    parser.add_argument('-t', action='store_true', default=False,
                        dest='boolean_switch',
                        help='Set a switch to true')
    parser.add_argument('-f', action='store_false', default=False,
                        dest='boolean_switch',
                        help='Set a switch to false')
    
    parser.add_argument('-a', action='append', dest='collection',
                        default=[],
                        help='Add repeated values to a list',
                        )
    
    parser.add_argument('-A', action='append_const', dest='const_collection',
                        const='value-1-to-append',
                        default=[],
                        help='Add different values to list')
    parser.add_argument('-B', action='append_const', dest='const_collection',
                        const='value-2-to-append',
                        help='Add different values to list')
    
    parser.add_argument('--version', action='version', version='%(prog)s 1.0')
    
    results = parser.parse_args()
    print 'simple_value     =', results.simple_value
    print 'constant_value   =', results.constant_value
    print 'demo_switch      =', results.demo_switch
    print 'boolean_switch   =', results.boolean_switch
    print 'collection       =', results.collection
    print 'const_collection =', results.const_collection

def parse_args():
    parser = MyParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-m', default="aiff", choices=['aiff', 'plot', 'demo'], help="which mode to use")
    parser.add_argument('-r', type=int, default=0, help="integer > 0 for sample rate to override default")
    parser.add_argument('files', nargs='*', help="file(s)")
    args = parser.parse_args()
    
    # no input args, so just show doc help
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)    

    if not args.m == 'demo':
        print "mode = %s," % args.m,
        if args.r:
            print "sample rate = {} sa/sec,".format(args.r),
        else:
            print "sample rate = native,",
        print "file count = %d" % len(args.files)
    else:
        print "mode = %s," % args.m

    print 'next'
    
# get inputs and run
def main():
    """get inputs and run"""

    args = parse_args()
    raise SystemExit

    # demo
    if sys.argv[1].lower() == 'demo':
        print 'demo mode'
        demo_chirp()

    # one file mode: both sound and plot file outputs for 1 input file
    elif len(sys.argv) == 2:
        print 'one file mode'
        filename = sys.argv[1]
        pad_file = PadFile(filename)
        convert(filename, samplerate=None, axis='xyzs', plot=True)

    # batch files mode: only sound file output for each input file
    else:
        print 'batch files mode'
        for filename in sys.argv[1:]:
            pad_file = PadFile(filename)
            convert(filename)

    sys.exit(0)

if __name__ == "__main__":
    main()
