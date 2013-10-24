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

# input parameters
defaults = {
'dateStart':    '2013-01-01', # see DateRange for flexibility on dateStart/dateStop inputs!
'dateStop':     '2013-10-21', # see DateRange for flexibility on dateStart/dateStop inputs!
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
            return 0
    parameters['dateRange'] = DateRange( parameters['dateStart'], parameters['dateStop'] )
    return 1 # all OK; otherwise, return 0 above

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

def formatAsPadString(dtm):
    return dtm.strftime('%Y_%m_%d_%H_%M_%S.%f')[:-3] # trim trailing zeros

def runResample(sensor, hdrFiles06Hz, hdrFilesFcHz, maxTimeDiff, dryRun, logProcess):
    """compare when 6 Hz stops relative to last fc Hz PAD via times from header filenames"""

    phfLowpass = PadHeaderFile(hdrFiles06Hz[-1])
    start6, stop6 = phfLowpass.getTimeRangeFromName()
    
    phfOriginal = PadHeaderFile(hdrFilesFcHz[-1])
    start, stop = phfOriginal.getTimeRangeFromName()
    
    tdelta = stop - stop6
    hourDelta = tdelta.seconds/3600.0
    if tdelta > maxTimeDiff:
        logProcess.warning( "#"*88 )
        logProcess.warning( "NOT OKAY %s stops ~%04.1f hours before %s according to PAD header filenames" % (sensor + '006', hourDelta, sensor) )
        logProcess.warning( "%s is stop time gleaned from last  6 Hz PAD header filename" % stop6 )
        logProcess.warning( "%s is stop time gleaned from last fc Hz PAD header filename" % stop )
        logProcess.warning( "#"*88 )
        dateStart = formatAsPadString( stop6 + datetime.timedelta(seconds=1) )
        dateStop =  formatAsPadString( stop6.date() + datetime.timedelta(days=1) )
        cmdstr = "date && python /home/pims/dev/programs/python/packet/resample.py fcNew=6 dateStart=%s dateStop=%s sensor=%s && date" % (dateStart, dateStop, sensor)
        if dryRun:
            cmdstr = "date && echo python /home/pims/dev/programs/python/packet/resample.py fcNew=6 dateStart=%s dateStop=%s sensor=%s && date" % (dateStart, dateStop, sensor)
        timeLogRun(cmdstr, 5400, logProcess) # timeout of 5400 seconds for 90 minutes
        return True
    else:
        return False

def runMatlabSuperfine(sensor, d, dryRun, logProcess):
    """run generate_vibratory_roadmap_superfine on ike for this day/sensor"""
    #cmdstr = 'ssh ike /home/pims/dev/programs/bash/backfillsuperfine.bash 29-Aug-2013 30-Aug-2013 "sams*_accel_*121f03"'
    cmdstr = 'ssh ike /home/pims/dev/programs/bash/backfillsuperfine.bash %s %s "*_accel_*%s"' % (d.strftime('%Y-%m-%d'), d.strftime('%Y-%m-%d'), sensor)
    if dryRun:
        cmdstr = 'echo ' + cmdstr
    timeLogRun(cmdstr, 3600, logProcess) # timeout of 3600 seconds for 60 minutes
    return True

def runIkePythonRoadmap(dateRange, dryRun, logProcess):
    """run processRoadmap.py on ike to get new PDFs into the fold"""
    # ssh ike 'cd /home/pims/roadmap && python /home/pims/roadmap/processRoadmap.py logLevel=3 mode=repair repairModTime=5 | grep nserted'
    repairYear = dateRange.start.strftime('%Y')
    cmdstr = "ssh ike 'cd /home/pims/roadmap && python /home/pims/roadmap/processRoadmap.py logLevel=3 mode=repair repairModTime=5 repairYear=%s | grep Inserted'" % repairYear
    if dryRun:
        cmdstr = "echo ssh ike 'cd /home/pims/roadmap && python /home/pims/roadmap/processRoadmap.py logLevel=3 mode=repair repairModTime=5 repairYear=%s \| grep Inserted'" % repairYear
    timeLogRun(cmdstr, 900, logProcess) # timeout of 900 seconds for 15 minutes
    return True

def backfill_ossbtmf_roadmaps(dateRange, logProcess):
    """
    Convert daily ossbtmf roadmap JPGs to PDFs and move for web display
    for entirety of dateRange.
    """
    logProcess.info('Starting in on dateRange %s' % dateRange)

    # Loop over days in dateRange
    d = dateRange.stop
    while d >= dateRange.start:
        if needToRun(d):
            logProcess.info('Working on day is %s' % d)
            runBackfill(d)
        else:
            logProcess.info('Working on day is %s' % d)
        d -= datetime.timedelta(days=1)

    ## Run ssh ike python routine for db population of spectrogram PDFs (if needed)
    #if needToRunIkeDatabase:
    #    runIkePythonRoadmap(dateRange, dryRun, logProcess)
    #
    ## Code to process data goes here
    #if not needToRunIkeMatlab and not needToRunIkeDatabase:
    #    logProcess.info('Nothing to do')
    
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
                backfill_ossbtmf_roadmaps(parameters['dateRange'], log.process)
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