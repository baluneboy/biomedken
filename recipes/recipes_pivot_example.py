#!/usr/bin/env python

import sys
from pyvttbl import DataFrame
from dateutil import parser, relativedelta

def convert_relativedelta_to_seconds(rdelta):
    return rdelta.days*86400.0 + rdelta.hours*3600.0 + rdelta.minutes*60.0 + rdelta.seconds + rdelta.microseconds/1.0e6

def main(fname):
    df = DataFrame()
    df.read_tbl(fname)
    df['gmtStart'] = [ parser.parse(i) for i in df['start'] ]
    df['gmtStop'] = [ parser.parse(i) for i in df['stop'] ]
    
    deltas = []
    for a,b in zip( df['gmtStart'], df['gmtStop'] ):
        rdelta = convert_relativedelta_to_seconds( relativedelta.relativedelta(b, a) )
        deltas.append( rdelta )
    df['gap_sec'] = deltas
    
    del df['start'], df['stop']
    
    print df
    
if __name__ == '__main__':
    main( sys.argv[1] )