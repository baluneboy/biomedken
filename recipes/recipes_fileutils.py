#!/usr/bin/env python

import os
import re
import time

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

if __name__ == "__main__":
    dirpath = '/home/pims/temp/sams/samslogs014'
    pattern = '.*\.gz$'
    demo_show_matches(dirpath, pattern)