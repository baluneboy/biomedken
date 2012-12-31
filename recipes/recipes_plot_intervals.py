#!/usr/bin/env python

import matplotlib.pyplot as plt
from matplotlib.dates import DateFormatter, HourLocator, MinuteLocator
import numpy as np
from StringIO import StringIO
import datetime


### The example data ###
a = StringIO("""
a 2012-12-31/12:15:22 2012-12-31/22:15:30 OK
b 2012-12-31/23:45:33 2013-01-01/11:05:40 OK
c 2013-01-01/11:25:40 2013-01-01/19:44:55 OK
""")

# Converts str into a datetime object.
conv = lambda s:datetime.datetime.strptime(s,'%Y-%m-%d/%H:%M:%S')

# Use numpy to read the data in. 
data = np.genfromtxt(a, converters={1: conv, 2: conv}, names=['caption','start','stop','state'], dtype=None)
cap, start, stop = data['caption'], data['start'], data['stop']

# Build y values from the number of unique captions.
y = np.empty(len(start))
y.fill(2)

hLines = plt.hlines(y, start, stop, color='b', lw=4)
ax = plt.gca()
ax.xaxis_date()
myFmt = DateFormatter('%H:%M')
ax.xaxis.set_major_formatter(myFmt)
ax.xaxis.set_major_locator(HourLocator(interval=2))

# To adjust the xlimits a timedelta is needed.
delta = (stop.max()-start.min())/10

plt.ylim(0,5)
plt.xlim(start.min()-delta, stop.max()+delta)
plt.xlabel('Time')
plt.show()

np.genfromtxt()