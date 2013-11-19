#!/usr/bin/env python

__all__ = [
    '_BATCHROADMAPS_PATTERN',
    ]

#/misc/yoda/www/plots/batch/year2013/month09/day29/2013_09_29_00_00_00.000_121f03_spgs_roadmaps500.pdf
_BATCHROADMAPS_PATTERN = (
    "(?P<ymdpath>.*)"                                       # perhaps a path at the start, then
    "(?P<dtm>\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}\.\d{3})"   # underscore-delimited dtm part of fname, then
    "_(?P<sensor>.*)_(?P<abbrev>.*)_roadmaps(?P<rate>.*)"   # placeholders for sensor, plot type, rate, then
    "\.pdf\Z"                                               # pdf extension to finish
    )

def match_batch_roadmaps_file(fname):
    """
    Check for match of _BATCHROADMAPS_PATTERN
    """
    import re
    return re.match(_BATCHROADMAPS_PATTERN, fname)

if __name__ == "__main__":
    m = match_batch_roadmaps_file('/misc/yoda/www/plots/batch/year2013/month09/day29/2013_09_29_00_00_00.000_121f03_spgs_roadmaps500.pdf')
    print m.group('sensor'), m.group('dtm')
