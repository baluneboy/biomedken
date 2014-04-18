#!/usr/bin/env python

import os
import re
import sys
import datetime
import operator
import shutil
import subprocess
from scipy import stats
from pims.utils.pimsdateutil import datetime_to_ymd_path

# get list of (file, rate) tuples sorted by rate
def file_rate_tuples(r):
    """get list of (file, rate) tuples sorted by rate"""
    regex = re.compile('(.*):.*SampleRate\>(.*)\<.*')
    my_list = [ (m.group(1), float(m.group(2))) for i in r for m in [regex.search(i)] if m ]
    my_list.sort( key=operator.itemgetter(1) )
    return my_list

# grep to get file and sample rate in list
def grep_sample_rate(subdir):
    """grep to get file and sample rate in list"""
    # grep SampleRate /misc/yoda/pub/pad/year2014/month04/day12/sams2_accel_121f02/*.header
    if not os.path.exists(subdir):
        raise OSError('%s does not exist' % subdir)
    cmd = 'grep SampleRate ' + os.path.join(subdir,'*.header')
    process = subprocess.Popen(cmd, shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    out, err = process.communicate()
    splitout = out.split('\n')[:-1] # split on newlines & get rid of very last trailing newline
    return splitout

# process single subdir to see if/what needs to be quarantined
def process(subdir):
    """process single subdir to see if/what needs to be quarantined"""
    # get list of (file, rate) tuples sorted by rate
    r = grep_sample_rate(subdir)
    my_list = file_rate_tuples(r)
    #print my_list

    # determine mode (most common) for sample rate    
    rates = [ t[1] for t in my_list ]
    mode = stats.mode(rates)[0][0]
    #print mode
    
    # get list to be quarantined (sample rate not equal to mode)
    quarantined_list = [ t for t in my_list if t[1] != mode ]
    
    # if needed, then move to quarantined
    qdir = os.path.join(subdir, 'quarantined')
    if quarantined_list and not os.path.isdir(qdir):
            os.mkdir( qdir )
    for f, fs in quarantined_list:
        #print 'move %s to %s' % (f, qdir)
        #print 'move %s to %s' % (f.rstrip('.header'), qdir)
        shutil.move(f, qdir)                    # move header file
        shutil.move(f.rstrip('.header'), qdir)  # move data file

# iterate over day directory (only sams2 subdirs for now)
def main(daydir):
    """iterate over day directory (only sams2 subdirs for now)"""
    # get sams2 directories
    subdirs = [ i for i in os.listdir(daydir) if os.path.isdir(os.path.join(daydir, i)) ]
    sams2_subdirs = [ i for i in subdirs if i.startswith('sams2_accel_') ]
    check_dirs = [ os.path.join(daydir, sd) for sd in sams2_subdirs ]
    for sams2dir in check_dirs:
        process(sams2dir)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        d2 = datetime.datetime.now().date() - datetime.timedelta(days=2)
        daydir = datetime_to_ymd_path(d2)
    else:
        daydir = sys.argv[1]
    main(daydir)