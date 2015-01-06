#!/usr/bin/env python

import re
import sys
from cStringIO import StringIO
import pandas as pd
from pims.patterns.dbstatuspats import _DBSTATUSLINE_PATTERN

_KEEP_SENSORS = ['121f02', '121f03', '121f04', '121f05', '121f08', 'es03', 'es05', 'es06', 'oss', 'hirap']

# return dataframe converted from stdin (file) object
def stdin_to_dataframe():
    """return dataframe converted from stdin (file) object"""
    buf = StringIO()
    buf.write('computer,sensor,count,mintime,maxtime,age\n')
    got_topline = False
    # sys.stdin is a file object, so all the same functions that
    # can be applied to a file object can be applied to sys.stdin    
    for line in sys.stdin.readlines():
        if got_topline:
            m = re.match(_DBSTATUSLINE_PATTERN, line)
            if m:
                buf.write( '%s,%s,%s,%s,%s,%s\n' % (m.group('computer'), m.group('sensor'), m.group('count'), m.group('mintime'), m.group('maxtime'), m.group('age')) )
            else:
                buf.write( 'no match\n' )        
        if re.match('.*COMPUTER.*', line):
            line = line.replace('_', ' ')
            line = line.replace('-', ' ')
            got_topline = True
    
     # "rewind" to the beginning of the StringIO object
    buf.seek(0)
    
    # read buf StringIO object as CSV into dataframe
    df = pd.read_csv(buf)

    # replace min/max times that are either zero or "None" with '1970-01-01 00:00:00'
    dict_replace = {'^0$': '1970-01-01 00:00:00', 'None': '1970-01-01 00:00:00'}
    df.replace(to_replace={'mintime': dict_replace, 'maxtime': dict_replace}, inplace=True)
    
    return df

# write right-aligned html converted from dataframe to stdout
def right_align_html(df):
    """write right-aligned html converted from dataframe to stdout"""
    buf_html = StringIO()
    df.to_html(buf_html, index=False, na_rep='nan')
    s = buf_html.getvalue()
    s = s.replace('<tr>', '<tr style="text-align: right;">')
    sys.stdout.write( s )            

# filter dataframe to keep "typical active sensors"
def filter_active_sensors(df):
    df = df[df['sensor'].isin(_KEEP_SENSORS)]
    df.sort(columns='sensor', axis=0, ascending=True, inplace=True)
    return df

# dbstatus.py | dbstatushtml.py > /tmp/trash2.html
if __name__ == "__main__":
    df = stdin_to_dataframe()
    
    # filter out for "Active Sensors" page
    df_filt = filter_active_sensors(df)
    
    # for piped output write html
    right_align_html(df_filt)