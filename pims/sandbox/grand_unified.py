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

# read tab-delimited file (not csv, because some cells have commas)
tab_file = '/home/pims/Downloads/scratch.csv'
df = pd.read_csv(tab_file, sep='\t')

# get rid of rows that have NaN as a value for "set"
df = df[ ~np.isnan(df['set']) ]
df['gmt'] = df['date'].map(parse)

# group by tag to get unique tags
g = df.groupby(['gmt', 'tag'])
for utag, dfss in iter(g):
    print utag
    print dfss
    print '-' * 33