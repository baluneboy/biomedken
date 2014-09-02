#!/usr/bin/env python
version = '$Id$'

import os
import sys
import datetime
from pims.database.pimsquery import db_connect, mysql_con
import pandas.io.sql as psql
import MySQLdb

# TODO
# - robustness for missing table (or go out and find hosts/tables automagically)
# - iterate over list of sensors
# - better way to get expected packets per second (SAMS/MAMS HiRAP, SampleRate, what else)
# - some form of pivot table to show results
# - allow more than 23 hours of history (the GROUP BY in MySQL call mucks this up othewise)

#### input parameters
###defaults = {
###'sensor':           '121f03',       # sensor = table name
###'packets_per_sec':  '8',            # expected value for this sensor for this gap check period
###'host':             'tweek',        # like tweek for 121f03
###'min_pct':          '0',            # show hourly periods with pkt count < min_pct (USE ZERO TO SHOW ALL)
###'hours_ago':        '23',           # start checking this many hours ago
###}

# defaults
defaults = {
'sensorhosts': [
    ('121f02',  'kenny'),
    ('121f03',  'tweek'),
    ('121f04',  'mr-hankey'),
    ('121f05',  'chef'),
    ('121f08',  'timmeh'),
    ('es03',    'butters'),
    ('es05',    'ike'),
    ('es06',    'butters')
    ],          
'packets_per_sec':  '8',    # expected value for this sensor for this gap check period
'min_pct':          '0',    # show hourly periods with pkt count < min_pct (USE ZERO TO SHOW ALL)
'hours_ago':        '23',   # start checking this many hours ago
}
parameters = defaults.copy()

class DatabaseGaps(object):
    """
    Info on database gaps given sensor (i.e. table), host, and expected packets per second.
    """
    def __init__(self, sensor='121f03', host='tweek', packets_per_sec=8, hours_ago=23, min_pct=0):
        """Initialize."""
        self.sensor = sensor
        self.host = host
        self.packets_per_sec = packets_per_sec
        self.hours_ago = hours_ago
        self.expect_packet_count = self.packets_per_sec * 3600.0 # count for one hour's worth          
        self.min_pct = min_pct
        self.start, self.stop = self._get_times()
        self.dataframe = None
        # dataframe formatters (for db query to dataframe)
        self.formatters = dict([
        ('%s pct'  % self.sensor,   lambda x: ' %3d%%' % x),
        ('%s pkts' % self.sensor,   lambda x: ' %d' % x)
        ])

    def __str__(self):
        s = ''
        s += 'sensor = %s\n' % self.sensor
        s += 'packets/sec = %s\n' % self.packets_per_sec
        s += 'hours_ago = %s\n' % self.hours_ago
        s += 'expect_packet_count = %s\n' % self.expect_packet_count
        s += 'host = %s\n' % self.host
        s += 'min_pct = %s\n' % self.min_pct
        s += 'start = %s\n' % self.start
        s += 'stop  = %s' % self.stop
        if self.dataframe:
            s += 'dataframe...\n'
            s += self.dataframe.to_string(formatters=self.formatters, index=False)
        else:
            s += 'no dataframe (yet)'
        return s

    def _get_times(self):
        """Get start/stop times."""
        now = datetime.datetime.now()
        rnd = datetime.timedelta(minutes=now.minute % 60, seconds=now.second, microseconds=now.microsecond)
        stop = now - rnd + datetime.timedelta(hours=1)
        start = now - rnd - datetime.timedelta(hours=self.hours_ago)
        return  start, stop

    def _dataframe_query(self):
        """count number of packets expected for hourly chunks""" 
        query =  'SELECT FROM_UNIXTIME(time) as "hour", '
        #query += 'ROUND(100*COUNT(*)/8.0/3600.0) as "pct", '
        #query += 'COUNT(*) as "pkts" from %s ' % self.sensor
        query += 'ROUND(100*COUNT(*)/8.0/3600.0) as "%s pct", ' % self.sensor
        query += 'COUNT(*) as "%s pkts" from %s ' % (self.sensor, self.sensor)
        query += 'WHERE FROM_UNIXTIME(time) >= "%s" ' % self.start.strftime('%Y-%m-%d %H:%M:%S')
        query += 'AND FROM_UNIXTIME(time) < "%s" ' % self.stop.strftime('%Y-%m-%d %H:%M:%S')
        query += "GROUP BY DATE_FORMAT(FROM_UNIXTIME(time), '%H') ORDER BY time;"
        #print query
        con = mysql_con(host=self.host, db='pims')
        self.dataframe = psql.frame_query(query, con=con)
        
    def filt_min_pct(self):
        """if min_pct is non-zero, then return filtered dataframe"""
        if self.min_pct == 0:
            df_gaps = self.dataframe
        else:
            df_gaps = self.dataframe[self.dataframe['pct'] < self.min_pct]
        return df_gaps

    def filter(self, predicate):
        """return filtered dataframe"""
        pass

def params_okay():
    """Not really checking for reasonableness of parameters entered on command line."""
    # check if sensorhosts not an input argument (list)
    if not isinstance(parameters['sensorhosts'], list):
        # first, split sensorhosts, each pairing separated by commas
        tmp = parameters['sensorhosts'].split(',')
        # next, split each pairing into tuple of (sensor, host)
        parameters['sensorhosts'] = [ tuple(i.split('_')) for i in tmp ]
    parameters['packets_per_sec'] = float(parameters['packets_per_sec'])
    parameters['min_pct'] = float(parameters['min_pct'])
    parameters['hours_ago'] = int(parameters['hours_ago'])
    if parameters['hours_ago'] > 23:
        print 'FIXME: currently MySQL GROUP BY mucks up queries longer than 23 hours ago'
        return False
    return True

def print_usage():
    """Print short description of how to run the program."""
    print version
    print 'usage: %s [options]' % os.path.abspath(__file__)
    print '       options (and default values) are:'
    for i in defaults.keys():
        print '\t%s=%s' % (i, defaults[i])
    
def main(argv):
    """script to simply check/show gaps in db"""
    # parse command line
    for p in sys.argv[1:]:
        pair = p.split('=')
        if (2 != len(pair)):
            print 'bad parameter: %s' % p
            break
        else:
            parameters[pair[0]] = pair[1]
    else:
        if params_okay():
            
            for sensor, host in parameters['sensorhosts']:
                print sensor, host
                try:
                    # first, get all info on gaps
                    dbgaps = DatabaseGaps(
                        sensor=sensor,
                        host=host,
                        packets_per_sec=parameters['packets_per_sec'],
                        min_pct=parameters['min_pct'],
                        hours_ago=parameters['hours_ago'],
                        )
                    dbgaps._dataframe_query()
                    # filter using min_pct
                    df_gaps = dbgaps.filt_min_pct()
                    # get result into string
                    msg = df_gaps.to_string(formatters=DF_FORMATTERS, index=False)
    
                except Exception as e:
                    msg = "Exception %s" % e.message
    
                print msg or 'done'
            return 0

    print_usage()  

if __name__ == '__main__':
    sys.exit(main(sys.argv))
