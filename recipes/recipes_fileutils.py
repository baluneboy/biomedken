#!/usr/bin/env python

import os
import re
import time
import datetime
from dateutil import parser
import re
from pyvttbl import DataFrame

def getSubdirs(parentDir):
    return [ name for name in os.listdir(parentDir) if os.path.isdir(os.path.join(parentDir, name)) ]

def filterSubdirs(parentDir, regexPatString):
    subDirs = getSubdirs(parentDir)
    regex = re.compile(regexPatString)
    return [m.group(0) for m in [regex.match(subDir) for subDir in subDirs] if m]

def printFilteredSubdirs(parentDir, regexPatString):
    for sd in filterSubdirs(parentDir, regexPatString):
        print os.path.join(parentDir, sd)

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

def put_in_quarantined(fname):
    import shutil
    d = os.path.dirname(fname)
    f = os.path.basename(fname)
    q = os.path.join(d, 'quarantined')
    s = os.path.join(d, fname.replace('.header','*') )
    if not os.path.isdir(q):
        os.makedirs(q)
    shutil.move( fname.replace('.header',''), q)
    shutil.move( fname, q)
    return

def demo_grep_matches(dirpath, pattern, query):
    """walk dirpath and show regex matches of filenamePattern that contain query string"""
    fullfile_pattern = os.path.join(dirpath, pattern)
    print 'filter_filenames matching pattern "%s"\n================================' % fullfile_pattern
    for fname in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
        with open(fname) as f:
                if query not in f.read():
                    #print '%s DOES NOT HAVE "%s"' % (fname, query)
                    put_in_quarantined(fname)
                #else:
                #    print '%s HAS "%s"' % (fname, query)

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

def underscore_to_dtm(s):
    return datetime.datetime.strptime(s,'%Y_%m_%d_%H_%M_%S.%f')

def parse_roadmap_filename(f):
    """ (\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}\.\d{3})_(.*)_(.*)_roadmaps(.*)\.pdf """
    pattern = '(\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}\.\d{3})_(.*)_(.*)_roadmaps(.*)\.pdf$'
    srch = re.compile(pattern).search
    m = srch(f)
    if m:
        dtm = underscore_to_dtm(m.group(1))
        sensor = m.group(2)
        abbrev = m.group(3)
        return dtm, sensor, abbrev, os.path.basename(f)
    else:
        return 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', "%s" % os.path.basename(f)
    
def pivot_table_insert_day_roadmaps(df, d=datetime.date.today()-datetime.timedelta(days=2), batchpath='/misc/yoda/www/plots/batch', pattern='.*roadmaps.*\.pdf$'):
    """walk dirpath and show regex matches of filenamePattern"""
    dirpath = os.path.join( batchpath, d.strftime('year%Y/month%m/day%d') )
    fullfile_pattern = os.path.join(dirpath, pattern)
    for f in filter_filenames(dirpath, re.compile(fullfile_pattern).match):
        dtm, sensor, abbrev, bname = parse_roadmap_filename(f)
        dat = dtm.date()
        hr = dtm.hour
        df.insert({'date':dat, 'hour':hr, 'sensor':sensor, 'abbrev':abbrev, 'bname':bname, 'fname':f})

def get_oldest_file(files, _invert=False):
    """ Find and return the oldest file of input file names.
    Only one wins tie. Values based on time distance from present.
    Use of `_invert` inverts logic to make this a youngest routine,
    to be used more clearly via `get_youngest_file`.
    """
    gt = operator.lt if _invert else operator.gt
    # Check for empty list.
    if not files:
        return None
    # Raw epoch distance.
    now = time.time()
    # Select first as arbitrary sentinel file, storing name and age.
    oldest = files[0], now - os.path.getctime(files[0])
    # Iterate over all remaining files.
    for f in files[1:]:
        age = now - os.path.getctime(f)
        if gt(age, oldest[1]):
            # Set new oldest.
            oldest = f, age
    # Return just the name of oldest file.
    return oldest[0]

def get_youngest_file(files):
    return get_oldest_file(files, _invert=True)

def file_age_diff_minutes(pth):
    """ Example of file age oldest/youngest. """
    os.chdir(pth)
    files = os.listdir(pth)
    oldest = min(files, key=os.path.getctime)
    newest = max(files, key=os.path.getctime)
    return (os.path.getctime(newest)-os.path.getctime(oldest))/60.0

def get_6hz_subdirs(top):
    sd = []
    for root, subdirs, files in os.walk(top, True):
        for subdir in subdirs:
            if subdir.endswith('006'):
                sd.append( os.path.join(root,subdir) )
    return sd

def demo_what(day, dStop):
    df = DataFrame()
    day = datetime.date(2013,7,1)
    dStop = datetime.date(2013,8,5)
    pattern = '.*_121f0\d{1}one_.*roadmaps.*\.pdf$' # '.*roadmaps.*\.pdf$'
    while day <= dStop:
        pivot_table_insert_day_roadmaps(df, d=day, pattern=pattern)
        day += datetime.timedelta(days=1)
    pt = df.pivot('abbrev', ['date'],['sensor'], aggregate='count')
    print pt
    
# EXAMPLE
#pth = '/misc/yoda/pub/pad/year2013/month06' #/sams2_accel_121f08006'
#subdirs = get_6hz_subdirs(pth)
#for sd in subdirs:
#    dur = file_age_diff_minutes(sd)
#    print '%6.1f minutes for %s in %s' % (dur, os.path.basename(sd), sd)
#raise SystemExit

if __name__ == "__main__":
    
    #######################################################################
    # Simply walk/show files (recursively under dirpath) that match pattern
    #dirpath = '/misc/yoda/pub/pad/year2013'
    #pattern = '.*sams2_accel_121f0.006$'
    #demo_show_matches(dirpath, pattern)
    
    #######################################################################
    # Forgot what this does, something to do with files' modified times   
    #dirpath = '/tmp/pad/year2013/month06/day28/sams2_accel_121f02'
    #pattern = '.*\.header$'
    #finfo = demo_show_file_deltas(dirpath, pattern)
    #for i in sorted(finfo, key=lambda x: x[0]):
    #    print i[0], i[-1]

    ##################################################################################################################
    # Do walk/search files (recursively under dirpath) that fname matches pattern & file does NOT contain query string
    #dirpath = '/misc/yoda/pub/pad/year2013/month06'
    #pattern = '.*\.121f04.header$'
    #demo_grep_matches(dirpath, pattern, 'SampleRate>500.0')
    
    ##################################################################################
    # Simply walk/show filtered subdirs (recursively under dirpath) that match pattern
    #regexPatString = 'sams2_accel_121f0\d{1}$|mams_accel_hirap$|mma_accel_.*|samses_accel_.*'
    #parentDir = '/misc/yoda/pub/pad/year2013/month05/day27'
    #printFilteredSubdirs(parentDir, regexPatString)
    
    #################################################################
    # Walk/parse files (recursively under dirpath) that match pattern
    #dirpath = '/misc/yoda/www/plots/batch/year2013/month07/day22'
    #pattern = '.*roadmaps.*\.pdf$'
    df = DataFrame()
    day = datetime.date(2013,7,1)
    dStop = datetime.date(2013,8,5)
    pattern = '.*_121f0\d{1}one_.*roadmaps.*\.pdf$' # '.*roadmaps.*\.pdf$'
    while day <= dStop:
        pivot_table_insert_day_roadmaps(df, d=day, pattern=pattern)
        day += datetime.timedelta(days=1)
    pt = df.pivot('abbrev', ['date'],['sensor'], aggregate='count')
    print pt
