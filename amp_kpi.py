#!/usr/bin/env python

# TODO
# csv read outputFile and produce kpi graphics

import re
import csv
from pandas import read_csv, pivot_table
import numpy as np
from legacy_pad_times_tally import *

def crit(label):
    _SAMS_HOURS_PATTERN = 'sams.*_hours'
    _MAMS_HOURS_PATTERN = 'mams_ossraw.*_hours|mams_hirap.*_hours'
    regex = re.compile(_SAMS_HOURS_PATTERN)
    print label
    return regex.match(label)
    
# read CSV into dataframe (for pivot tables)
def csv2dataframe(csvfile):
    """read CSV into dataframe (for pivot tables)"""
    ###with open(csvfile, 'rb') as f:
    ###    labels = f.next().strip().split(',')
    ###df = DataFrame()
    ###df.read_tbl(csvfile)
    
    ##z = zip(df['sams_121f02_hours'], df['sams_121f03_hours'])
    ##a  = df['sams_121f02_hours']
    ##a += df['sams_121f03_hours']
    ##print z[100:109]
    ##print a[100:109]
    ##raise SystemExit
    ##df['twothree_hours'] = [ a + b for a,b in zip(df['sams_121f02_hours'], df['sams_121f03_hours']) ]
    ##labels.append('twothree_hours')
    
    #args = []
    #for s in [2,3,4,5,6,8]:
    #    args.append( df['sams_121f0' + str(s) + '_hours'] )
    ##args = [ df['sams_121f02_hours'], df['sams_121f03_hours'] ]
    #sams_sum_hours = []
    #for t in izip(*args):
    #    sams_sum_hours.append(np.sum(t))
    #df['sams_sum_hours'] = sams_sum_hours
    #labels.append('sams_sum_hours')

    with open(csvfile, 'rb') as f:
        labels = f.next().strip().split(',')
    df = read_csv(csvfile)
    
    print df
    df.filter(regex='sams.*_hours')
    print df[:,['sams_121f02_hours', 'sams_es06_hours']]

    raise SystemExit

    

    sams_columns = [m.group(0) for m in [regex.match(label) for label in labels] if m]
    
    df_sams_hours = df[sams_columns]
    #print df_sams_hours
    print df
    #col_sums = df_sams_hours.sum()

    #for idx in [0, 199, 255, 777]:
    #    print idx, np.round( df23[idx] - df['sams_121f02_hours'][idx] - df['sams_121f03_hours'][idx], decimals=6 )

    #return df, labels

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
