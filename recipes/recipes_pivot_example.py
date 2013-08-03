#!/usr/bin/env python

import sys
from pyvttbl import DataFrame
from dateutil import parser, relativedelta
import numpy as np

def convert_relativedelta_to_seconds(rdelta):
    return rdelta.days*86400.0 + rdelta.hours*3600.0 + rdelta.minutes*60.0 + rdelta.seconds + rdelta.microseconds/1.0e6

def demo1(fname):
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

def demo2(fname):
    df = DataFrame()
    df.read_tbl(fname)
    df['approx'] = [ np.around(i,decimals=0) for i in df['pct'] ]
    pt = df.pivot('approx', ['gmt'], ['sensor'])
    print pt
   
if __name__ == '__main__':
    #demo1( sys.argv[1] )
    demo2( sys.argv[1] )