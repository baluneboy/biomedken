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

def demo_show_matches(dirpath, filenamePattern):
    """walk dirpath and show regex matches of filenamePattern"""
    fullFilePattern = os.path.join(dirpath, filePattern)
    print 'filter_filenames matching pattern "%s"\n================================' % fullFilePattern
    for f in filter_filenames(dirpath, re.compile(fullFilePattern).match):
        print "%s" % f    

if __name__ == "__main__":
    dirpath = '/Users/ken/Desktop/music23/zmusic'
    filePattern = '(.*)-(.*)'
    demo_show_matches(dirpath, filePattern)