#!/usr/bin/env python

import os
import re
import time

def fileAgeDays(pathname):
    return ( time.time() - os.path.getmtime(pathname) ) / 86400.0

def filter_filenames(dirpath, predicate):
    """Usage:
           >>> filePattern = '\d{14}.\d{14}/\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}.\d{3}.\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}.\d{3}.*'
           >>> for filename in filter_filenames('/misc/jaxa', re.compile(r'/misc/jaxa/' + filePattern).match):
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
    dirpath = '/tmp/tgz'
    pattern = '/tmp/tgz/usr/diskless/ee122-f0[12]/root/var/log/messages$'
    demo_show_matches(dirpath, pattern)