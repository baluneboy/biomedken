#!/usr/bin/env python

__all__ = [
    '_PADHEADERFILES_PATTERN',
    '_BATCHROADMAPS_PATTERN',
    ]

#/misc/yoda/pub/pad/year2013/month11/day01/sams2_accel_121f05/2013_11_01_23_52_29.944-2013_11_02_00_02_29.959.121f05.header
_PADHEADERFILES_PATTERN = (
    "(?P<ymdpath>.*)"                                       # perhaps a path at the start, then
    "(?P<start>\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}\.\d{3})" # underscore-delimited start part of fname, then
    "(?P<pm>[\+\-])"                                        # plus/minus
    "(?P<stop>\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}\.\d{3})"  # underscore-delimited stop part of fname, then
    "\.(?P<sensor>.*)"                                      # dot sensor
    "\.header\Z"                                            # pdf extension to finish
    )


#/misc/yoda/www/plots/batch/year2013/month09/day29/2013_09_29_00_00_00.000_121f03_spgs_roadmaps500.pdf
_BATCHROADMAPS_PATTERN = (
    "(?P<ymdpath>.*)"                                       # perhaps a path at the start, then
    "(?P<start>\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}\.\d{3})" # underscore-delimited dtm part of fname, then
    "_(?P<sensor>.*)_(?P<abbrev>.*)_roadmaps(?P<rate>.*)"   # placeholders for sensor, plot type, rate, then
    "\.pdf\Z"                                               # pdf extension to finish
    )

def match_pattern_demo(fname, pat):
    """Check for match."""
    import re
    return re.match(pat, fname)

if __name__ == "__main__":
    #m = match_pattern_demo('/misc/yoda/www/plots/batch/year2013/month09/day29/2013_09_29_00_00_00.000_121f03_spgs_roadmaps500.pdf', _BATCHROADMAPS_PATTERN)
    #print m.group('sensor'), m.group('dtm')

    m = match_pattern_demo('/misc/yoda/pub/pad/year2013/month11/day01/sams2_accel_121f05/2013_11_01_23_52_29.944-2013_11_02_00_02_29.959.121f05.header', _PADHEADERFILES_PATTERN)
    print m.group('sensor'), m.group('start')