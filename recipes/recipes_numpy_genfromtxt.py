#!/usr/bin/env python

import numpy as np
import datetime
from StringIO import StringIO

def getDemoData():
    """ example data """
    
    # a file-like object to read from via numpy
    a = StringIO("""
    a 2012-12-31/02:15:22 2012-12-31/22:15:30 OK
    b 2012-12-31/23:45:33 2013-01-01/11:05:40 BAD
    c 2013-01-01/11:25:40 2013-01-01/19:44:55 OK
    """)
    
    # Converts str into a datetime object.
    conv = lambda s:datetime.datetime.strptime(s,'%Y-%m-%d/%H:%M:%S')
    
    # Use numpy to read the data in. 
    data = np.genfromtxt(a, converters={1: conv, 2: conv}, names=['caption','start','stop','state'], dtype=None)
    caption, start, stop, state = data['caption'], data['start'], data['stop'], data['state']
    
    return caption, start, stop, state

def showDemo():
    """
    
    >>> showDemo()
    a 31-Dec-2012/02:15:22 31-Dec-2012/22:15:30 OK
    b 31-Dec-2012/23:45:33 01-Jan-2013/11:05:40 BAD
    c 01-Jan-2013/11:25:40 01-Jan-2013/19:44:55 OK
    
    """
    
    fmt = '%d-%b-%Y/%H:%M:%S'
    # Build y values from the number of start values
    caption, start, stop, state = getDemoData()
    for cap,t1,t2,cond in zip(caption,start,stop,state):
        print cap, t1.strftime(fmt), t2.strftime(fmt), cond

def testdoc():
    import doctest
    return doctest.testmod()

if __name__ == "__main__":
    testdoc() # pass "-v" as input arg to see verbose test output