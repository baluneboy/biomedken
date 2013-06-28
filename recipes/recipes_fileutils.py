#!/usr/bin/env python

import os
import re
import time
import datetime

def fileAgeDays(pathname):
    return ( time.time() - os.path.getmtime(pathname) ) / 86400.0

def filter_filenames(dirpath, predicate):
    """Usage:
           >>> filePattern = '\d{14}.\d{14}/\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}.\d{3}.\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}.\d{3}.*'
           >>> dirpath = '/misc/jaxa'
           >>> predicate = re.compile(r'/misc/jaxa/' + filePattern).match
           >>> for filename in filter_filenames(dirpath, predicate):
           ....    # do something
    """
    for root, dirnames, filenames in os.walk(dirpath):
        for filename in filenames:
            abspath = os.path.join(root, filename)
            if predicate(abspath):
                yield abspath

def demo_show_matches(dirpath, pattern):
    """walk dirpath and show regex matches of filenamePattern"""
    fullfile_pattern = os.path.join(dirpath, pattern)
    print 'filter_filenames matching pattern "%s"\n================================' % fullfile_pattern
    for f in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
        print "%s" % f    

def get_file_mod_time(fname):
    #time = time.strftime("%d/%m/%Y %H:%M:%S",time.localtime(os.path.getctime(fname)))
    fmtime =  time.strftime("%d/%m/%Y %H:%M:%S",time.localtime(os.path.getmtime(fname)))
    dtm = datetime.datetime.strptime(fmtime, "%d/%m/%Y %H:%M:%S")
    return dtm
    #fatime =  time.strftime("%d/%m/%Y %H:%M:%S",time.localtime(os.path.getatime(fname)))
    #fsize = os.path.getsize(fname)
    #print "size = %0.1f kb" % float(fsize/1000.0)
    #fctimestat = time.ctime(os.stat(fname).st_ctime)
    #print fname + '\nfctime: ' + fctime + '\nfmtime: ' + fmtime + '\nfatime: ' + fatime + '\n',
    #print 'fctimestat: ' + fctimestat + '\n',
    #print 'fsize:', fsize,

def demo_show_file_deltas(dirpath, pattern):
    """walk dirpath and show regex matches of filenamePattern"""
    from recipes_regex import get_data_end_time
    fullfile_pattern = os.path.join(dirpath, pattern)
    print 'filter_filenames matching pattern "%s"\n================================' % fullfile_pattern
    file_info = []
    for f in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
        dtmFileModified = get_file_mod_time(f)
        dtmDataEnds = get_data_end_time(f)
        delta = dtmFileModified - dtmDataEnds
        #print "%s DELTA = %s" % (f, delta)
        file_info.append( (f, dtmFileModified, dtmDataEnds, delta) )
    return file_info

if __name__ == "__main__":
    #dirpath = '/home/pims/temp/sams/samslogs014'
    #pattern = '.*\.gz$'
    #demo_show_matches(dirpath, pattern)
    dirpath = '/tmp/pad/year2013/month06/day27/sams2_accel_121f02'
    pattern = '.*\.header$'
    finfo = demo_show_file_deltas(dirpath, pattern)
    for i in sorted(finfo, key=lambda x: x[-1]):
        print i[0], i[-1]
