#!/usr/bin/env python

import datetime
import pandas as pd
import numpy as np
from cStringIO import StringIO

# parse date from input text file
def parse(s):
    """parse date from input text file"""
    m, d, y = s.split('/')
    mo = int(m)
    da =  int(d)
    yr = int(y)
    d = datetime.date(yr, mo, da)
    return d

# getr rid of NaN and dash in timestr
def replace_timestr(t):
    """getr rid of NaN and dash in timestr"""
    if isinstance(t, float):
        return None
    if '-' == t:
        return None
    return t

# read tab-delimited file (not csv, because some cells have commas)
tab_file = '/home/pims/dev/programs/python/pims/sandbox/data/scratch.csv'
df = pd.read_csv(tab_file, sep='\t')

# get rid of rows that have NaN as a value for "set"
df = df[ ~np.isnan(df['set']) ]
df['gmt'] = df['date'].map(parse)

# fix timestr (mostly, but still a string)
df['range'] = df['Maneuver Start-Stop GMT'].map(replace_timestr)

# group by tag to get/work on unique tags
grp = df.groupby(['gmt', 'tag'])
for tag, dfss in iter(grp):
    print tag[0], tag[1]
    
    # group by set number to get/work set-by-set
    setgrp = dfss.groupby('set')
    for s, dfset in iter(setgrp):
        #print dfset
        print 'set %04d' % s,
        ypr = [ i for i in dfset['YPR'] ]
        print np.round(ypr, decimals=1),
        times = [ i for i in dfset['range'] ]
        print times,
        events = [ i for i in dfset['Event'] ]
        print events

    print '=' * 44