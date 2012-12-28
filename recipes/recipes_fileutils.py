#!/usr/bin/env python

import os
import re

def filter_filenames(dirpath, predicate):
    """Usage:
           >>> filePattern = '\d{14}.\d{14}/\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}.\d{3}.\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}.\d{3}.*'
           >>> for filename in filter_filenames('/misc/jaxa', re.compile(r'/misc/jaxa/' + filePattern).match):
           ....    # do something
    """
    for dir_, dirnames, filenames in os.walk(dirpath):
        for filename in filenames:
            abspath = os.path.join(dir_, filename)
            if predicate(abspath):
                yield abspath

if __name__ == "__main__":
    dirpath = '/misc/jaxa'
    filePattern = '\d{14}.\d{14}/\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}.\d{3}.\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}.\d{3}.*'
    fullFilePattern = os.path.join(dirpath, filePattern)
    print 'filter_filenames matching pattern "%s"\n================================' % fullFilePattern
    for f in filter_filenames(dirpath, re.compile(fullFilePattern).match):
        print "%s" % f