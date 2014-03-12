#!/usr/bin/env python
"""
Date/time functions mostly for PIMS/PAD utility.
"""

import os
import datetime
import time
from dateutil import parser

MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY = range(7)

(JANUARY, FEBRUARY, MARCH, APRIL, MAY, JUNE,
 JULY, AUGUST, SEPTEMBER, OCTOBER, NOVEMBER, DECEMBER) = range(1, 13)

_DAY = datetime.timedelta(1)

def floor_ten_minutes(t):
    """Return datetime rounded down (floored) to nearest 10-minute mark.
    
    >>> floor_ten_minutes( datetime.datetime(2012,12,31,23,39,59,999000) )
    datetime.datetime(2012, 12, 31, 23, 30)
    """
    return t - datetime.timedelta( minutes=t.minute % 10,
                                    seconds=t.second,
                                    microseconds=t.microsecond)

def datetime_to_ymd_path(d, base_dir='/misc/yoda/pub/pad'):
    """
    Return PAD path for datetime, d, like /misc/yoda/pub/pad/yearYYYY/monthMM/dayDD
    
    Examples
    --------
    
    >>> datetime_to_ymd_path(datetime.date(2002, 12, 28))
    '/misc/yoda/pub/pad/year2002/month12/day28'
    
    >>> datetime_to_ymd_path(datetime.datetime(2009, 12, 31, 23, 59, 59, 999000))
    '/misc/yoda/pub/pad/year2009/month12/day31'
    
    """
    return os.path.join( base_dir, d.strftime('year%Y/month%m/day%d') )

def timestr_to_datetime(timestr):
    """
    Return datetime representation of a time string.
    
    Examples
    --------
    
    >>> timestr_to_datetime('2013_01_02_00_01_02.210')
    datetime.datetime(2013, 1, 2, 0, 1, 2, 210000)
    
    """
    return datetime.datetime.strptime(timestr,'%Y_%m_%d_%H_%M_%S.%f')

def format_datetime_as_pad_underscores(dtm):
    """
    Format datetime as underscore-delimited PAD string.
    
    >>> format_datetime_as_pad_underscores( datetime.datetime(2013,10,25,1,2,3,456789) ) # NO ROUNDING!
    '2013_10_25_01_02_03.456'
    
    """
    return dtm.strftime('%Y_%m_%d_%H_%M_%S.%f')[:-3] # remove 3 trailing zeros

def days_ago_string(n):
    """Return n days ago as YYYY_mm_dd string."""
    n_days_ago = datetime.date.today()-datetime.timedelta(n)
    return n_days_ago.strftime('%Y_%m_%d')    

_2DAYSAGO = days_ago_string(2).replace('_', '-')

def days_ago_path_path(base_dir,n):
    """Return PAD path for n days ago like PADPATH/yearYYYY/monthMM/dayDD"""
    date_n_days_ago = datetime.date.today()-datetime.timedelta(n)
    return os.path.join( base_dir, date_n_days_ago.strftime('year%Y/month%m/day%d') )

def days_ago_to_date(n): 
    """Convert daysAgo integer to date object."""
    return datetime.date.today()-datetime.timedelta(n)
    
def days_ago_to_datetime(n):
    """Convert daysAgo integer to date object."""
    d = days_ago_to_date(n)
    return datetime.datetime.combine(d, datetime.time(0))

def is_leap_year(dt):
    """True if date in a leap year, False if not.

    >>> for year in 1900, 2000, 2100, 2001, 2002, 2003, 2004:
    ...     print year, is_leap_year(datetime.date(year, 1, 1))
    1900 False
    2000 True
    2100 False
    2001 False
    2002 False
    2003 False
    2004 True
    """
    return (datetime.date(dt.year, 2, 28) + _DAY).month == 2

def days_in_month(dt):
    """Total number of days in date's month.

    >>> for y in 2000, 2001:
    ...     print y,
    ...     for m in range(1, 13):
    ...         print "%d:%d" % (m, days_in_month(datetime.date(y, m, 1))),
    ...     print
    2000 1:31 2:29 3:31 4:30 5:31 6:30 7:31 8:31 9:30 10:31 11:30 12:31
    2001 1:31 2:28 3:31 4:30 5:31 6:30 7:31 8:31 9:30 10:31 11:30 12:31
    """
    if dt.month == 12:
        return 31
    else:
        next = datetime.date(dt.year, dt.month+1, 1)
        return next.toordinal() - dt.replace(day=1).toordinal()
    
def hours_in_month(dt):
    """Total number of hours in date's month.

    >>> for y in 1999, 2000, 2001:
    ...     print y,
    ...     for m in range(1, 13):
    ...         dt = datetime.date(y, m, 1)
    ...         print "%d:%d:%d" % (m, days_in_month(dt), hours_in_month(dt)),    
    ...     print
    1999 1:31:744 2:28:672 3:31:744 4:30:720 5:31:744 6:30:720 7:31:744 8:31:744 9:30:720 10:31:744 11:30:720 12:31:744
    2000 1:31:744 2:29:696 3:31:744 4:30:720 5:31:744 6:30:720 7:31:744 8:31:744 9:30:720 10:31:744 11:30:720 12:31:744
    2001 1:31:744 2:28:672 3:31:744 4:30:720 5:31:744 6:30:720 7:31:744 8:31:744 9:30:720 10:31:744 11:30:720 12:31:744
    """
    days = days_in_month(dt)
    return days * 24
    
def first_weekday_on_or_after(weekday, dt):
    """First day of kind MONDAY .. SUNDAY on or after date.

    The time and tzinfo members (if any) aren't changed.

    >>> base = datetime.date(2002, 12, 28)  # a Saturday
    >>> base.ctime()
    'Sat Dec 28 00:00:00 2002'
    >>> first_weekday_on_or_after(SATURDAY, base).ctime()
    'Sat Dec 28 00:00:00 2002'
    >>> first_weekday_on_or_after(SUNDAY, base).ctime()
    'Sun Dec 29 00:00:00 2002'
    >>> first_weekday_on_or_after(TUESDAY, base).ctime()
    'Tue Dec 31 00:00:00 2002'
    >>> first_weekday_on_or_after(FRIDAY, base).ctime()
    'Fri Jan  3 00:00:00 2003'
    """
    days_to_go = (weekday - dt.weekday()) % 7
    if days_to_go:
        dt += datetime.timedelta(days_to_go)
    return dt

def first_weekday_on_or_before(weekday, dt):
    """First day of kind MONDAY .. SUNDAY on or before date.

    The time and tzinfo members (if any) aren't changed.

    >>> base = datetime.date(2003, 1, 3)  # a Friday
    >>> base.ctime()
    'Fri Jan  3 00:00:00 2003'
    >>> first_weekday_on_or_before(FRIDAY, base).ctime()
    'Fri Jan  3 00:00:00 2003'
    >>> first_weekday_on_or_before(TUESDAY, base).ctime()
    'Tue Dec 31 00:00:00 2002'
    >>> first_weekday_on_or_before(SUNDAY, base).ctime()
    'Sun Dec 29 00:00:00 2002'
    >>> first_weekday_on_or_before(SATURDAY, base).ctime()
    'Sat Dec 28 00:00:00 2002'
    """

    days_to_go = (dt.weekday() - weekday) % 7
    if days_to_go:
        dt -= datetime.timedelta(days_to_go)
    return dt

def weekday_of_month(weekday, dt, index):
    """Return the index'th day of kind weekday in date's month.

    All the days of kind weekday (MONDAY .. SUNDAY) are viewed as if a
    Python list, where index 0 is the first day of that kind in dt's month,
    and index -1 is the last day of that kind in dt's month.  Everything
    follows from that.  The time and tzinfo members (if any) aren't changed.

    Example:  Sundays in November.  The day part of the date is irrelevant.
    Note that a "too large" index simply spills over to the next month.

    >>> base = datetime.datetime(2002, 11, 25, 13, 22, 44)
    >>> for index in range(5):
    ...     print index, weekday_of_month(SUNDAY, base, index).ctime()
    0 Sun Nov  3 13:22:44 2002
    1 Sun Nov 10 13:22:44 2002
    2 Sun Nov 17 13:22:44 2002
    3 Sun Nov 24 13:22:44 2002
    4 Sun Dec  1 13:22:44 2002

    Start from the end of the month instead:
    >>> for index in range(-1, -6, -1):
    ...     print index, weekday_of_month(SUNDAY, base, index).ctime()
    -1 Sun Nov 24 13:22:44 2002
    -2 Sun Nov 17 13:22:44 2002
    -3 Sun Nov 10 13:22:44 2002
    -4 Sun Nov  3 13:22:44 2002
    -5 Sun Oct 27 13:22:44 2002
    """
    if index >= 0:
        base = first_weekday_on_or_after(weekday, dt.replace(day=1))
        return base + datetime.timedelta(weeks=index)
    else:
        base = first_weekday_on_or_before(weekday,
                                          dt.replace(day=days_in_month(dt)))
        return base + datetime.timedelta(weeks=1+index)

def days_ago_to_date(n): 
    """Convert days_ago integer, n, to date object."""
    return datetime.date.today()-datetime.timedelta(n)
    
def days_ago_to_date_time(n):
    """Convert days_ago integer, n, to date object."""
    d = days_ago_to_date(n)
    return datetime.datetime.combine(d, datetime.time(0))

def unix2dtm(u):
    """convert a unix time u to a datetime object"""
    return datetime.datetime.utcfromtimestamp(u)

# FIXME this does not give milli-second resolution [maybe total_seconds fault?]
def dtm2unix(d):
    """convert a datetime object to unix time (seconds since 01-Jan-1970)"""
    return (d - datetime.datetime(1970,1,1)).total_seconds()

# convert input time from string to unixtime float
def parse_packetfeeder_input_time(s, sec_plot_span):
    """
    convert string input for packetfeeder.py
    SUBTRACT sec_plot_span if input is zero float string
    """
    try:
        f = float(s)
        if f > 0.0:
            return f
        elif f == 0:
            # convenient end time
            dtm = parser.parse('2064-12-02 23:59:59')
            return dtm2unix(dtm)
        else:
            raise Exception('no negative unixtime floats accepted')
    except ValueError:
        dtm = parser.parse(s)
        return dtm2unix(dtm)

def testdoc(verbose=True):
    import doctest
    return doctest.testmod(verbose=verbose)

if __name__ == "__main__":
    testdoc(verbose=True)
