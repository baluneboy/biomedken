#!/usr/bin/env python

import matplotlib.pyplot as plt
from matplotlib.dates import DateFormatter, HourLocator, MinuteLocator
import numpy as np
import datetime
import sys

if sys.version_info > (2, 7):
    USETICKPARAMS = True
else:
    USETICKPARAMS = False

def plotIntervalSet(fig, ax, yval, start, stop, color='k', lw=6):
    """ plot interval data """
    
    # Generate y values from scalar yval
    y = np.empty(len(start))
    y.fill(yval)   
    
    # Set current axes
    fig.sca(ax)
    
    # Plot horizontal lines
    hLines = plt.hlines(y, start, stop, color, lw=lw)

def getDemoData():
    """ example data """
    from StringIO import StringIO

    # a file-like object to read from via numpy
    a = StringIO("""
    a 2012-12-31/02:15:22 2012-12-31/22:15:30 OK
    b 2012-12-31/23:45:33 2013-01-01/11:05:40 OK
    c 2013-01-01/11:25:40 2013-01-01/19:44:55 OK
    """)
    
    # Converts str into a datetime object.
    conv = lambda s:datetime.datetime.strptime(s,'%Y-%m-%d/%H:%M:%S')
    
    # Use numpy to read the data in. 
    data = np.genfromtxt(a, converters={1: conv, 2: conv}, names=['caption','start','stop','state'], dtype=None)
    cap, start, stop = data['caption'], data['start'], data['stop']
    
    # Let's ignore "caption" and "state" for this example
    yval = 2
    return yval, start, stop

def showDemo():
    # Build y values from the number of start values
    yval, start, stop = getDemoData()

    # Init figure and axes
    fig = plt.figure( figsize=(20,12), dpi=80 )
    ax = fig.add_axes([0.075, 0.1, 0.85,  0.85]) 
    
    hLines2 = plotIntervalSet(fig, ax, 2, start, stop, color='b', lw=2)
    hLines3 = plotIntervalSet(fig, ax, 3, start, stop)
    
    # Set major x ticks every 4 hours
    ax.xaxis_date()
    ax.xaxis.set_major_locator( HourLocator( byhour=[ 0,  8, 16 ] ) )
    ax.xaxis.set_minor_locator( HourLocator( byhour=[ 4, 12, 20 ] ) )   
    ax.xaxis.set_major_formatter( DateFormatter('%H:%M\n%d-%b-%Y') )
    ax.xaxis.set_minor_formatter( DateFormatter('%H:%M') )    
    
    # To adjust the xlimits a timedelta is needed.
    delta = (stop.max()-start.min())/20
    ax.set_ylim([0, 5])
    ax.set_xlim([start.min()-delta, stop.max()+delta])
    xLabel = ax.set_xlabel('GMT (HH:MM)')
    
    if USETICKPARAMS:
        # Make tick_params more suitable to your liking...
        plt.tick_params(axis='both', which='both', width=2, direction='out')
        # tick_params for x-axis
        plt.tick_params(axis='x', which='major', labelsize=12, length=8)
        plt.tick_params(axis='x', which='minor', labelsize=12)
        plt.tick_params(axis='x', which='minor', length=6, colors='gray')
        # tick_params for y-axis
        plt.tick_params(axis='y', which='both', labelsize=12)
        plt.tick_params(right=True, labelright=True)
    else:
        print 'matplotlib version prohibits use of tick_params'
    
    ax.xaxis.grid(True,'minor')
    ax.xaxis.grid(True,'major',linewidth=2)
    
    plt.savefig('/tmp/trash.pdf')
    plt.show()
    

def demo2():
    import random
    # A generator to get datetimes (every 5 minutes start on 31-Dec-2012)
    def nextFiveMinutes():
        dtm = datetime.datetime(2012, 12, 31, 22, 0, 0) - datetime.timedelta(minutes=5)
        while 1:
            dtm += datetime.timedelta(minutes=5)
            yield (dtm)
    
    # Generate dummy data
    nd = nextFiveMinutes()
    num = 38
    some_dates = [nd.next() for i in range(0,num)] #get 20 dates
    y_values = [random.randint(1,100) for i in range(0,num)] # get dummy y data
    
    # Figure and axis objects
    fig = plt.figure()
    ax = fig.gca()
    
    # Plotting goes here ...
    ax.plot_date(some_dates, y_values, 'b.-')
    ax.set_xlabel('GMT (hh:mm)')
    
    # Set major x ticks every so often
    ax.xaxis.set_major_locator( MinuteLocator(byminute=[0, 30, 60]) )
    ax.xaxis.set_minor_locator( MinuteLocator(byminute=[15, 45]) )
    ax.xaxis.set_major_formatter( DateFormatter('%H:%M\n%d-%b-%Y') )
    ax.xaxis.set_minor_formatter( DateFormatter('%H:%M') )
    
    if USETICKPARAMS:
        # Make tick_params more suitable to your liking...
        plt.tick_params(axis='both', which='both', width=2, direction='out')
        # tick_params for x-axis
        plt.tick_params(axis='x', which='major', labelsize=12, length=8)
        plt.tick_params(axis='x', which='minor', labelsize=12)
        plt.tick_params(axis='x', which='minor', length=6, colors='gray')
        # tick_params for y-axis
        plt.tick_params(axis='y', which='both', labelsize=12)
        plt.tick_params(right=True, labelright=True)
    
    plt.show()

if __name__ == '__main__':
    showDemo()
    demo2()