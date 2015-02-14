#!/usr/bin/env python

import datetime
import pandas.io.data as web

start = datetime.datetime(2001,8,1)
end = datetime.datetime(2015,2,7)
pn = web.DataReader(('SNXFX', 'SKSEX', 'SWHGX', 'GTCSX'), 'yahoo', start, end)
print pn['Adj Close']

df = pn.to_frame()
print df