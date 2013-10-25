#!/usr/bin/env python
version = '$Id$'

# DONE 1. For each day, find where PAD 006 leaves off (compare PAD end times: "006 vs. original cutoff") to find premature stoppage
#
# TODO 2. Smartly clean-up dangling "resample" and "octave" processes, BUT these must be "stale" processes by some measure
#          -- also, get rid of "stale" PAD dir ".tmp" files
#
# DONE 3. Pickup resample where any 006 left off (run as NOT dry-run)
#       -- use special sensor/start/stop form of input to resample (each sensor separately, not pattern), as follows:
#          >> python /home/pims/dev/programs/python/packet/resample.py fcNew=6 dateStart=START dateStop=DAYEND sensor=SENSOR
#       -- do ike matlab roadmap
#       -- do ike python db roadmap processing
#
# TODO 4. Finally verify days/sensors that needed remedy (run again as dry-run)

import os
import sys
import re
import datetime
from dateutil import parser
from datetimeranger import DateRange
from padpro import PadIntervalSet, PadHeaderFile
from check_spectrograms import PimsDayCache, PimsDaySensorCacheWithSampleRate
from recipes_command_timeout_log import Command, timeLogRun
import numpy as np
import time
import subprocess
import threading
from pims.files.log import OssbtmfBackfillRoadmapsLog
from pims.utils.pimsdateutil import datetime_to_ymd_path
from pims.files.utils import listdir_filename_pattern
from pims.utils.commands import timeLogRun

# input parameters
defaults = {
'dateStart':    '2013-01-01', # see DateRange for flexibility on dateStart/dateStop inputs!
'dateStop':     '2013-10-21', # see DateRange for flexibility on dateStart/dateStop inputs!
'batch_dir':    '/misc/yoda/www/plots/batch', # where to look for JPGs needed for PDF convert
}
parameters = defaults.copy()

def parametersOK():
    """check for reasonableness of parameters entered on command line"""    
    try:
        parameters['dateStart'] = parser.parse( parameters['dateStart'] )
        parameters['dateStop'] = parser.parse( parameters['dateStop'] )
    except ValueError, e:
            # Log error
            logging.error('Bad input trying to parse date got ValueError: "%s"' % e.message )
            return False
    parameters['dateRange'] = DateRange( parameters['dateStart'], parameters['dateStop'] )
    
    if not os.path.exists(parameters['batch_dir']):
        return False

    return True

def printUsage():
    """print short description of how to run the program"""
    print version
    print 'usage: %s [options]' % os.path.abspath(__file__)
    print '       options (and default values) are:'
    for i in defaults.keys():
        print '\t%s=%s' % (i, defaults[i])

def recordInputs( logInps ):
    logInps.info( '='*50 )
    for k,v in parameters.iteritems():
        logInps.info( k + ':' + str(v) )
    logInps.info( '='*20 )
    logInps.info( 'START = %s' % parameters['dateRange'].start.strftime('%Y-%m-%d') )
    logInps.info( 'STOP  = %s' % parameters['dateRange'].stop.strftime('%Y-%m-%d') )
    logInps.info( '='*20 )

def check_for_pdfs(day, batch_dir):
    """Check for ossbtmf roadmap PDF files for input day."""
    pdf_path = datetime_to_ymd_path(day, base_dir=batch_dir)
    fname_pattern = day.strftime('%Y_%m_%d_\d{2}_ossbtmf_roadmap.pdf')
    pdf_files = listdir_filename_pattern(pdf_path, fname_pattern)
    qs_dir = os.path.join(batch_dir, 'Quasi-steady')
    jpg_path = datetime_to_ymd_path(day, base_dir=qs_dir)
    jpg_files = listdir_filename_pattern(jpg_path, fname_pattern.replace('.pdf', '.jpg') )
    if len(pdf_files) == 0:
        bln = True
    else:
        bln = False
    return bln, jpg_files

def run_backfill(day, batch_dir, jpg_files, logProcess):
    """Convert JPGs to PDFs and move the PDFs to batch dir."""
    #cmdstr = 'ssh ike /home/pims/dev/programs/bash/backfillsuperfine.bash %s %s "*_accel_*%s"' % (d.strftime('%Y-%m-%d'), d.strftime('%Y-%m-%d'), sensor)
    #timeLogRun(cmdstr, 120, logProcess) # timeout of 120 seconds for 2 minutes
    ymd_path = datetime_to_ymd_path(day, base_dir=batch_dir)
    count = 0
    if jpg_files:
        for jpg_file in jpg_files:
            pdf_file = jpg_file.replace('.jpg','.pdf')
            cmdstr = 'convert %s %s && mv %s %s/' % (jpg_file, pdf_file, pdf_file, ymd_path)
            timeLogRun(cmdstr, 44, logProcess) # timeout of 44 seconds
            count += 1
    return count

def run_ike_repair(years, logProcess):
    """Run processRoadmap.py on ike to get new PDFs into the fold"""
    # ssh ike 'cd /home/pims/roadmap && python /home/pims/roadmap/processRoadmap.py logLevel=3 mode=repair repairModTime=5 | grep nserted'
    for repairYear in years:
        cmdstr = "ssh ike 'cd /home/pims/roadmap && python /home/pims/roadmap/processRoadmap.py logLevel=3 mode=repair repairModTime=5 repairYear=%d | grep Inserted'" % repairYear
        timeLogRun(cmdstr, 900, logProcess) # timeout of 900 seconds for 15 minutes

def backfill_ossbtmf_roadmaps(dateRange, batch_dir, logProcess):
    """
    Convert daily ossbtmf roadmap JPGs to PDFs and move for web display
    for entirety of dateRange.
    """
    logProcess.info('Starting in on dateRange %s' % dateRange)

    # Loop over days in dateRange
    repair_years = set( (dateRange.stop.year,) )
    num_days_backfilled = 0
    d = dateRange.stop
    while d >= dateRange.start:
        need_to_run, jpg_files = check_for_pdfs(d, batch_dir)
        if need_to_run:
            logProcess.info('Backfilling for day %s' % d.date())
            num_back_filled = run_backfill(d, batch_dir, jpg_files, logProcess)
            repair_years.add( d.year )
            num_days_backfilled += 1
        #else:
        #    logProcess.info('No need to backfill day %s' % d.date())
        d -= datetime.timedelta(days=1)
    
    # If any backfills, then do repair routine on ike
    if num_days_backfilled > 0:
        run_ike_repair(repair_years, logProcess)
    
def main(argv):
    """describe what this routine does here"""
    # parse command line
    for p in sys.argv[1:]:
        pair = p.split('=')
        if (2 != len(pair)):
            print 'bad parameter: %s' % p
            break
        else:
            parameters[pair[0]] = pair[1]
    else:
        if parametersOK():
            # Initialize verbose logging
            log = OssbtmfBackfillRoadmapsLog()
            recordInputs(log.inputs)
            try:
                backfill_ossbtmf_roadmaps(parameters['dateRange'], parameters['batch_dir'], log.process)
            except Exception, e:
                # Log error
                log.process.error( e.message )
                return -1
                
            # Message with time when done
            log.process.info('Logging done at %s.', datetime.datetime.now() )
            
            return 0
        
    printUsage()  

if __name__ == '__main__':
    sys.exit(main(sys.argv))