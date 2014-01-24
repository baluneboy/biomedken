#!/usr/bin/env python

# TODO
# csv read outputFile and produce kpi graphics

import re
import csv
from pandas import read_csv, pivot_table, concat, DataFrame
import numpy as np
from legacy_pad_times_tally import *
import matplotlib.pyplot as plt

# read CSV into dataframe (for pivot tables)
def csv2dataframe(csvfile):
    """read CSV into dataframe (for pivot tables)"""
    with open(csvfile, 'rb') as f:
        labels = f.next().strip().split(',')
    df = read_csv(csvfile)
    
    # monthly system hours
    ndf = df.filter(regex='Year|Month|Day|sams.*_hours')
    cols = [i for i in ndf.columns if i not in ['Year', 'Month', 'Day']]
    t = pivot_table(ndf, rows=['Year','Month'], values=cols, aggfunc=np.sum)
    sams_series = t.transpose().sum()
    
    ndf = df.filter(regex='Year|Month|Day|mams.*_hours')
    cols = [i for i in ndf.columns if i not in ['Year', 'Month', 'Day']]
    t = pivot_table(ndf, rows=['Year','Month'], values=cols, aggfunc=np.sum)
    mams_series = t.transpose().sum()

    print 'Monthly Totals of Sensor Hours'
    tdf = DataFrame({'SAMS': sams_series, 'MAMS':mams_series})
    
    tdf.plot()
    plt.show()
    csvout = '/tmp/out.csv'
    tdf.to_csv(csvout)
    print 'wrote %s' % csvout

    pass    
    
    #total = concat([sams_series, mams_series], axis=0)
    #print total

def main(csvfile):
    csv2dataframe(csvfile)
    #print df
    #print labels
        
if __name__ == '__main__':
    # parse command line
    for p in sys.argv[1:]:
        pair = split(p, '=', 1)
        if (2 != len(pair)):
            print 'bad parameter: %s' % p
            break
        if not parameters.has_key(pair[0]):
            print 'bad parameter: %s' % pair[0]
            break
        else:
            parameters[pair[0]] = pair[1]
    else:
        if parametersOK():
            csvfile = parameters['outputFile']
            main(csvfile)
            sys.exit(0)

    printUsage()
