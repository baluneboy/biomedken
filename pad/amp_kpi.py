#!/usr/bin/env python

import re
import sys
import csv
import numpy as np
import pandas as pd

# filter and pivot to get aggregate sum of monthly hours
def monthly_hours(df, s):
    """filter and pivot to get aggregate sum of monthly hours"""
    ndf = df.filter(regex='Date|Year|Month|Day|' + s + '.*_hours')
    cols = [i for i in ndf.columns if i not in ['Date', 'Year', 'Month', 'Day']]
    t = pd.pivot_table(ndf, rows=['Year','Month'], values=cols, aggfunc=np.sum)
    series = t.transpose().sum()
    return series

# put systems' monthly hours (each a series) into pd.DataFrame
def monthly_hours_dataframe(df, systems_series):
    """put systems' monthly hours (each a series) into pd.DataFrame"""
    for k, v in systems_series.iteritems():
        systems_series[k] = monthly_hours(df, k)    
    monthly_hours_df = pd.DataFrame(systems_series)
    monthly_hours_df.columns = [ s.upper() for s in monthly_hours_df.columns ]
    return monthly_hours_df

# read CSV into dataframe (for pivot tables)
def csv2dataframe(csvfile):
    """read CSV into dataframe (for pivot tables)"""
    with open(csvfile, 'rb') as f:
        labels = f.next().strip().split(',')
    df = pd.read_csv(csvfile, parse_dates=True, index_col = [0])
    return df

# produce output csv with per-system monthly sensor hours totals & rolling means
def main(csvfile):
    """produce output csv with per-system monthly sensor hours totals & rolling means"""
    # read input CSV into big pd.DataFrame
    df = csv2dataframe(csvfile)

    # systems' monthly hours (each a series from pivot) into dataframe
    systems_series = {'sams':None, 'mams':None}
    monthly_hours_df = monthly_hours_dataframe(df, systems_series)
    
    # pd.concat rolling means (most recent n months) into growing dataframe
    systems = list(monthly_hours_df.columns)
    original_mdf = monthly_hours_df.copy()
    num_months = [3, 6, 9]
    clip_value = 0.01
    for n in num_months:
        roll_mean = pd.rolling_mean(original_mdf, window=n)
        # rolling mean can produce tiny values, so let's clip/replace with zeros
        for system in systems:
            roll_mean[system] = roll_mean[system].clip(clip_value, None)
            roll_mean.replace(to_replace=clip_value, value=0.0, inplace=True)
        roll_mean.columns = [ i + '-%d' % n for i in systems]
        monthly_hours_df = pd.concat([monthly_hours_df, roll_mean], axis=1)
    
    # save csv output file
    csvout = csvfile.replace('.csv','_monthly.csv')
    monthly_hours_df.to_csv(csvout)
    print 'wrote %s' % csvout
        
if __name__ == '__main__':
    if len(sys.argv) > 1:
        csvfile = sys.argv[1]
    else:
        csvfile = '/misc/yoda/www/plots/batch/padtimes/padtimes.csv'
    main(csvfile)    