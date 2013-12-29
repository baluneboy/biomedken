#!/usr/bin/env python
version = '$Id$'
# Adapted from Ted Wright's packetWriter.py,v 1.22 2004-11-29 20:00:04 pims

# TODO see how things get initialized relative to CURRENT TIME, PLOT_SPAN, startTime, endTime, etc.
# TODO fix it so that rt_params['verbose.fileo'] is used for logging file path
# TODO get rid of inspect as input argument

import wx
import os
import re
import sys
import thread
import string
import math
import pickle
import struct
import socket
import numpy as np
import logging
import warnings
from time import * # FIXME
from io import BytesIO
from MySQLdb import * # FIXME
from commands import * # FIXME
from xml.dom.minidom import parseString as xml_parse

from pims.files.log import SimpleLog
from pims.realtime import rt_params # centralized place to keep real-time parameters
from pims.realtime.accelpacket import *
from pims.utils.pimsdateutil import unix2dtm
from pims.kinematics.rotation import rotation_matrix
from pims.database.pimsquery import ceil4, PadExpect
from pims.gui.stripchart import GraphFrame
from pims.lib.tools import varname
from pims.utils.benchmark import Benchmark
from pims.gui.stripchart import PimsRtTrace

from obspy import Trace
#from obspy.realtime import RtTrace

import inspect

def get_line():
    callerframerecord = inspect.stack()[1]    # 0 represents this line
                                              # 1 represents line at caller
    frame = callerframerecord[0]
    info = inspect.getframeinfo(frame)
    #print info.filename                       # __FILE__     -> Test.py
    #print info.function                       # __FUNCTION__ -> Main
    #print info.lineno                         # __LINE__     -> 13
    return info.lineno

# Absolute minimum time to leave data alone for it to settle and to allow other
# tasks to get access to it in the database (even if contiguous data is present after this)
MIN_DELAY = 2

# Wake up and process database every "SLEEP_TIME" seconds (this value is 30 *minutes* in packetWriter)
SLEEP_TIME = 4

# Max records in database request
MAX_RESULTS = 100 # nominal is 200; max sensor packet rate is like 14 pps (nominal is 8 pps)

# Max records to process before deleting processed data and/or working on another table for a while
MAX_RESULTS_PER_TABLE = 5 * 60 * 8 # use M * S/M * P/S; 4800 for 10-minute plot (for 8 pps & 5-minute plot, use 2400)

# Packet counters
PACKETS_WRITTEN = 0
PACKETS_DELETED = 0
TOTAL_PACKETS_FED = 0 # global variable for tracking if any progress is being made

DEFAULTS_LIST = [
    'ancillaryHost',       # the name of the computer with the auxiliary databases (or 'None')
    'host',                # the name of the computer with the database
    'database',            # the name of the database to process
    'tables',              # the database table that should be processed (NOT "ALL" & NOT separated by commas)
    'destination',         # the directory to write files into in scp format (host:/path/to/data) or local .
    'delete',              # 0=delete processed data, 1=leave in database OR use databaseName to move to that db
    'resume',              # try to pick up where a previous run left off, or do whole database
    'inspect',             # JUST INSPECT FOR UNEXPECTED CHANGES, DO NOT WRITE PAD FILES
    'showWarnings',        # show or supress warning message
    'ascii',               # write data in ASCII or binary
    'startTime',           # first data time to process (0 means anything back to 1970, negative for "good" start)
    'endTime',             # last data time to process (0 means no limit)
    'quitWhenDone',        # end this program when all data is processed
    'bigEndian',           # write binary data as big endian (Sun, Mac) or little endian (Intel)
    'cutoffDelay',         # maximum amount of time to keep data in the database before processing (sec)
    'maxFileTime',         # maximum time span for a PAD file (0 means no limit)
    'additionalHeader' ]   # additional XML to put in header.
                           #   in order to prevent confusion in the shell and command parser,
                           #   represent XML with: ' ' replaced by '#', tab by '~', CR by '~~'

# For convenience (legacy sake) populate DEFAULTS as strings (times in seconds)
DEFAULTS = {}
for var in DEFAULTS_LIST:
    DEFAULTS[var] = str( rt_params['pw.' + var] )

PARAMETERS = DEFAULTS.copy()
def setParameters(newParameters):
    global PARAMETERS
    PARAMETERS = newParameters.copy()
    
ANC_DATA = {}
ANC_DATA_FORMAT = {}
ANC_XML = ''
ANC_UPDATE = 0 # next time ANC_XML should by updated
ANC_DATABASES = ['bias', 'coord_system_db', 'data_coord_system', 'dqm', 'iss_config', 'scale']

#BENCH_NEXT_METHOD = Benchmark('next method') # this should avg about 3s
#BENCH_APPEND_METHOD = Benchmark('append method') # this should avg just under 11ms

################################################################
# sample idle function
# FIXME keeping track of previous total is kludge WHY/HOW?
PREV_IDLE_TOTAL = 0
def sample_idle_fun():
    """a sample idle function"""
    global PREV_IDLE_TOTAL
    if PREV_IDLE_TOTAL != TOTAL_PACKETS_FED:
        log.debug("%04d IDLER TOTAL_PACKETS_FED %d" % (get_line(), TOTAL_PACKETS_FED))
        sleep(0.1)
    PREV_IDLE_TOTAL = TOTAL_PACKETS_FED

# add sample idle function (NOTE: addIdle comes from pims.realtime.accelpacket)
addIdle(sample_idle_fun)
################################################################

# class to keep track of what's been fed
class PacketFeeder(object):
    """Class to keep track of what has been fed."""
    def __init__(self, showWarnings):
        """initialize this packet feeder"""
        self._showWarnings_ = showWarnings
        self.lastPacket = None
        self._file_ = None
        self._fileName_ = None
        self._fileStart_ = 0
        self._forceNewFile_ = 0
        self._fileSep_ = '-'
        self._dataCoordSystem_ = 'sensor' # NOTICE: 'sensor' means do NOT do any transformation
        self._rotateData_ = 0
        self._rotationMatrix_ = np.identity(3).astype(np.float32)
        self._headerPacket_ = None
        self._header_ = None
        self._dataDirName_ = "error" # should be replace by packet's dataDirName() function
        self._maybeMove_ = '' # indicator that a file has been generated and should eventually be moved
        log.debug('%s has been initialized.' % self.__class__.__name__)
    
    # DEFUNCT create the PIMS directory tree for pad files (locally)
    def buildDirTree(self, filename):
        """DEFUNCT # create the PIMS directory tree for pad files (locally)"""
        log.debug("%04d buildDirTree() input: %s" % (get_line(), filename) )
        s = split(filename, '-')
        if len(s) == 1:
            s = split(filename, '+')
        start, rest = s
        sensor = split(rest, '.')[-1]
        year, month, day, hour, min, sec = split(start, '_')
        y = 'year%s' % year
        m = 'month%s' % month
        d = 'day%s' % day
        command = "mkdir %s;" % (y)
        command = command + "mkdir %s/%s;" % (y, m)
        command = command + "mkdir %s/%s/%s;" % (y, m, d)
        command = command + "mkdir %s/%s/%s/%s;" % (y, m, d, self._dataDirName_)
        command = command + "mv %s %s.header %s/%s/%s/%s" % (filename, filename, y, m, d, self._dataDirName_)
        r = getoutput(command)
        if len(r) != 0:
            t =  UnixToHumanTime(time(), 1)
            t = t + ' buildDirTree() error:\nfilename: %s, error: %s' % (filename, r)
            print_log(t)
            return '%s' % (y)
        return '%s' % (y)
        
    # move PAD file
    def movePadFile(self, source):
        """move PAD file"""
        dest = PARAMETERS['destination']
        if dest == '.':
            return
        if source == '':
            t =  UnixToHumanTime(time(), 1)
            t = t + ' movePadFile() bad source: %s' % source
            print_log(t)
            return
        # build directory structure locally to avoid having to use ssh
        localPath = self.buildDirTree(source)
        retryDelay = 30
        retry = 1
        while retry:
            r = getoutput('scp -pr %s %s' % (localPath, dest))
            if len(r) != 0:
                t = UnixToHumanTime(time(), 1)
                t = t + ' movePadFile() error:\nsource: %s*, destination: %s, error: %s' % (localPath, dest, r)
                t = t +  '\n will try again in %s seconds' % retryDelay
                print_log(t)
                idleWait(retryDelay)
            else:
                retry = 0
        r = getoutput('rm -rf %s*' % (localPath))
        # getoutput('beep -f 4000 -l 50') 
        self._maybeMove_ = ''
        
    # return time of last packet (or zero)
    def lastTime(self):
        """return time of last packet (or zero)"""
        if self.lastPacket:
            return self.lastPacket.time()
        else:
            return 0

    # build XML header
    def buildHeader(self, dataFileName):
        """build XML header"""
        header = '<?xml version="1.0" encoding="US-ASCII"?>\n'
        header = header + '<%s>\n' % self._headerPacket_.type
        header = header + self._headerPacket_.xmlHeader() # extract packet specific header info
        if PARAMETERS['ascii']:
            format = 'ascii'
        else:
            if PARAMETERS['bigEndian']:
                format = 'binary 32 bit IEEE float big endian'
            else:
                format = 'binary 32 bit IEEE float little endian'
        header = header + '\t<GData format="%s" file="%s"/>\n' % (format, dataFileName)
        # insert additionalDQM() if necessary
        aXML = ANC_XML
        if self._headerPacket_.additionalDQM() != '':
            dqmStart = find(aXML, '<DataQualityMeasure>')
            if dqmStart == -1:
                aXML = aXML + '\t<DataQualityMeasure>%s</DataQualityMeasure>\n' % xmlEscape(self._headerPacket_.additionalDQM())
            else:
                dqmInsert = dqmStart + len('<DataQualityMeasure>')
                aXML = aXML[:dqmInsert] + xmlEscape(self._headerPacket_.additionalDQM()) + ', ' + aXML[dqmInsert:] 
        header = header + aXML
        if PARAMETERS['additionalHeader'] != '\"\"':
            header = header + PARAMETERS['additionalHeader']
        header = header + '</%s>\n' % self._headerPacket_.type
        return header
    
    # set the coordinate system we want the data to be in
    def setDataCoordSystem(self, dataName, dataTime, sensor = ''):
        """set the coordinate system we want the data to be in"""
        # sensor name is passed in because we might not have received any
        # real packets yet to determine sensor name for coord. transformation
        if dataName == self._dataCoordSystem_: 
            return 1 # no change
        if dataName == 'sensor' or dataName == sensor:
            self._rotateData_ = 0
            #self._rotationMatrix_ = identity(3).astype(Float32)
            self._rotationMatrix_ = np.identity(3).astype(np.float32)
            success = 1
        else:                
            sensorEntry, dataEntry = check_coord_sys(dataTime, sensor, dataName)
            if sensorEntry and dataEntry:
                self._rotateData_ = 1
                # use inverse matrix to get to ref system
                firstRot = rotation_matrix(sensorEntry[2], sensorEntry[3], sensorEntry[4], 1)
                # use forward matrix to get where we want to go
                secondRot = rotation_matrix(dataEntry[2], dataEntry[3], dataEntry[4], 0)
                #self._rotationMatrix_ =  matrixmultiply(secondRot, firstRot).astype(Float32)
                self._rotationMatrix_ =  np.dot(secondRot, firstRot).astype(np.float32)
                # transpose (invert) the rotation_matrix so that we can postMultiply the data
                self._rotationMatrix_ =  np.transpose(self._rotationMatrix_)
                success = 1
            else: # coord sys lookup failed
                self._rotateData_ = 0
                #self._rotationMatrix_ = identity(3).astype(Float32)
                self._rotationMatrix_ = np.identity(3).astype(np.float32)
                success = 0
        self._forceNewFile_ = 1 
        self._dataCoordSystem_ = dataName
        return success

    # DEFUNCT do whatever it takes to write the packet to disk
    def writePacket(self, packet, contiguous = -1):
        """DEFUNCT do whatever it takes to write the packet to disk"""
        global PACKETS_WRITTEN
        PACKETS_WRITTEN += 1
        #print "PACKETS_WRITTEN", PACKETS_WRITTEN
        #sleep(1)
        if self.lastPacket:
            ostart = self.lastPacket.time()
            oend = self.lastPacket.endTime()
            start = packet.time()
            log.debug('%04d writePacket() start: %0.10f end: %0.10f samples: %s packetGap: %0.10f  sampleGap: %0.10f' % (get_line(), start, packet.endTime(), packet.samples(), start-ostart, start-oend))

#        print 'writePacket ' + `contiguous`
        update_anc_data(packet.time(), packet.name(), self)
        if contiguous == -1:
            contiguous = packet.contiguous(self.lastPacket)
        if self._forceNewFile_:
            self.begin(packet, 0)
            self._forceNewFile_ = 0
        elif not contiguous or ((PARAMETERS['maxFileTime'] > 0) and (packet.time() > (self._fileStart_ + PARAMETERS['maxFileTime']))):
            self.begin(packet, contiguous)

        #BENCH_APPEND_METHOD.start()
        self.append(packet)
        #log.debug('%04d %s' % (get_line(), BENCH_APPEND_METHOD))


    # finished writing for a while, close and name the file if it was in use 
    def end(self):
        """finished writing for a while, close and name the file if it was in use"""
        if self._file_ != None:
            self._file_.close()
            self._file_ = None
            if self.lastPacket:
                newName = UnixToHumanTime(self._fileStart_) + self._fileSep_ + \
                      UnixToHumanTime(self.lastPacket.endTime()) + '.' + self.lastPacket.name()
                ok = os.system('mv %s %s' % (self._fileName_, newName)) == 0
                log.debug('%04d end() is moving %s to %s, success:%s' % (get_line(), self._fileName_, newName, ok))
                headFile = open(newName + '.header', 'wb')
                headFile.write(self.buildHeader(newName))  
                headFile.close()
                self._fileName_ = newName
                self._dataDirName_ = self.lastPacket.dataDirName()
                self._maybeMove_ = newName
            return self._fileName_

    # begin writing a new file
    def begin(self, packet, contiguous):
        self.end()
        if self._maybeMove_ != '':
            self.movePadFile(self._maybeMove_)

        self._headerPacket_ = packet # save header packet info for future header writing
        if contiguous:
            self._fileSep_ = '+'
        else:
            self._fileSep_ = '-'
            #print 'change starting with packet: ', packet.dump() # show interesting packet headers for now
            if self._showWarnings_ and self.lastPacket:
                if packet.time() < self.lastPacket.endTime()- 0.00005:
                    t = UnixToHumanTime(time(), 1)  
                    t = t + ' overlappingPacket\nprev: ' + self.lastPacket.dump() + '\nnext: ' + packet.dump()
                    print_log(t)
        self._fileName_ = 'temp.' + packet.name()
        self._file_ = open(self._fileName_, 'ab')
        self._fileStart_ = packet.time()
        log.debug('%04d begin() is NOT REALLY starting %s' % (get_line(), self._fileName_))

    # append data to the file, may need to reopen it
    def append(self, packet):
        global TOTAL_PACKETS_FED
        if self._file_ == None:
            newName = 'temp.' + packet.name()
            os.system('rm -rf %s.header' % self._fileName_)
            ok = os.system('mv %s %s' % (self._fileName_, newName)) == 0
            log.debug('%04d append() is moving %s to %s, success:%s' % (get_line(), self._fileName_, newName, ok))
            if not ok: # move failed, maybe file doesn't exist anymore
                contiguous = packet.contiguous(self.lastPacket)
                if contiguous:
                    self._fileSep = '+'
                else:
                    self._fileSep = '-'
                self._fileStart_ = packet.time()
            self._fileName_ = newName
            self._file_ = open(self._fileName_, 'ab')

        txyzs = packet.txyz()
        packetStart = packet.time()
        atxyzs = np.array(txyzs, np.float32)
        if  self._rotateData_ and 4 == len(atxyzs[0]):  # do coordinate system rotation
            atxyzs[:,1:] = np.dot(atxyzs[:,1:], self._rotationMatrix_ )
        atxyzs[:,0] = atxyzs[:,0] + np.array(packetStart-self._fileStart_, np.float32) # add offset to times

        aextra = None
        extra = packet.extraColumns()
        if extra:
            aextra = np.array(extra, np.float32)

        if not PARAMETERS['ascii']:
            if PARAMETERS['bigEndian']:
                atxyzs = atxyzs.byteswap() 
                if extra:
                    aextra = aextra.byteswap()
            if extra:
                atxyzs = concatenate((atxyzs, aextra), 1)
            self._file_.write(atxyzs.tostring())
        else:
            s= ''
            if extra:
                atxyzs = concatenate((atxyzs, aextra), 1)
            formatString = '%.4f'
            for col in atxyzs[0][1:]:
                formatString = formatString + ' %.7e'
            formatString = formatString + '\n'
            for row in atxyzs:
                s = s + formatString % tuple(row)
            self._file_.write(s)
        self.lastPacket = packet
        TOTAL_PACKETS_FED = TOTAL_PACKETS_FED + 1

# class to keep track of unexpected changes
class PacketInspector(PacketFeeder):
    """class to keep track of unexpected changes in header rate info"""
    # FIXME we may be able to streamline this more so by making some method
    #       routines do less/nothing; for now, just neutralize things a bit

    def buildDirTree(self, filename):
        """do nothing for inheritance sake"""        
        pass

    def movePadFile(self, source):
        """do nothing for inheritance sake"""
        pass

    # finished "non-writing" for a while, close and name the file if it was in use 
    def end(self):
        """finished non-writing for a while, NOT REALLY close and name the file if it was in use"""
        if self._file_ != None:
            self._file_.close()
            self._file_ = None
            if self.lastPacket:
                newName = UnixToHumanTime(self._fileStart_) + self._fileSep_ + \
                      UnixToHumanTime(self.lastPacket.endTime()) + '.' + self.lastPacket.name()
                ok = True #os.system('mv %s %s' % (self._fileName_, newName)) == 0
                log.debug('%04d end() is moving %s to %s, success:%s' % (get_line(), self._fileName_, newName, ok))
                #headFile = open(newName + '.header', 'wb')
                #headFile.write(self.buildHeader(newName))  
                #headFile.close()
                self._fileName_ = newName
                self._dataDirName_ = self.lastPacket.dataDirName()
                self._maybeMove_ = newName
            return self._fileName_

    # begin writing a new file
    def begin(self, packet, contiguous):
        self.end()
        if self._maybeMove_ != '':
            self.movePadFile(self._maybeMove_)

        self._headerPacket_ = packet # save header packet info for future header writing
        if contiguous:
            self._fileSep_ = '+'
        else:
            self._fileSep_ = '-'
            #print 'change starting with packet: ', packet.dump() # show interesting packet headers for now
            if self._showWarnings_ and self.lastPacket:
                if packet.time() < self.lastPacket.endTime()- 0.00005:
                    t = UnixToHumanTime(time(), 1)  
                    t = t + ' overlappingPacket\nprev: ' + self.lastPacket.dump() + '\nnext: ' + packet.dump()
                    print_log(t)
        self._fileName_ = 'temp.' + packet.name()
        #self._file_ = open(self._fileName_, 'ab')
        self._fileStart_ = packet.time()
        log.debug('%04d begin() is NOT REALLY starting %s' % (get_line(), self._fileName_))

    # append data NOT to the file, NOT REALLY need to reopen it
    def append(self, packet):
        """inspect packet for unexpected changes (do not append to file)"""
        global TOTAL_PACKETS_FED
        if self._file_ == None:
            newName = 'temp.' + packet.name()
            os.system('rm -rf %s.header' % self._fileName_)
            ok = True #os.system('mv %s %s' % (self._fileName_, newName)) == 0
            log.debug('%04d append() is NOT REALLY moving %s to %s, success:%s' % (get_line(), self._fileName_, newName, ok))
            if not ok: # move failed, maybe file doesn't exist anymore
                contiguous = packet.contiguous(self.lastPacket)
                if contiguous:
                    self._fileSep = '+'
                else:
                    self._fileSep = '-'
                self._fileStart_ = packet.time()
            self._fileName_ = newName
            #self._file_ = open(self._fileName_, 'ab') # this is okay, giving zero-length file
            self._file_ = BytesIO(self._fileName_) # FIXME w/o this or line above we run slow

        txyzs = packet.txyz()
        packetStart = packet.time()
        atxyzs = np.array(txyzs, np.float32)
        if  self._rotateData_ and 4 == len(atxyzs[0]):  # do coordinate system rotation
            atxyzs[:,1:] = np.dot(atxyzs[:,1:], self._rotationMatrix_ )
        atxyzs[:,0] = atxyzs[:,0] + np.array(packetStart-self._fileStart_, np.float32) # add offset to times

        aextra = None
        extra = packet.extraColumns()
        if extra:
            aextra = np.array(extra, np.float32)

        if not PARAMETERS['ascii']:
            if PARAMETERS['bigEndian']:
                atxyzs = atxyzs.byteswap() 
                if extra:
                    aextra = aextra.byteswap()
            if extra:
                atxyzs = concatenate((atxyzs, aextra), 1)
            #self._file_.write(atxyzs.tostring()) # NOTE THIS IS "NOT-WRITING" JUST INSPECTING
            #print atxyzs
        else:
            s= ''
            if extra:
                atxyzs = concatenate((atxyzs, aextra), 1)
            formatString = '%.4f'
            for col in atxyzs[0][1:]:
                formatString = formatString + ' %.7e'
            formatString = formatString + '\n'
            for row in atxyzs:
                s = s + formatString % tuple(row)
            #self._file_.write(s) # NOTE THIS IS "NOT-WRITING" JUST INSPECTING
            
        self.lastPacket = packet
        TOTAL_PACKETS_FED = TOTAL_PACKETS_FED + 1
    
# class to feed packet data hopefully to a good strip chart display
class PadGenerator(PacketInspector):
    """Generator for PimsRtTrace using real-time scaling."""
    def __init__(self, showWarnings=1, maxsec_rttrace=7200, scale_factor=1000):
        """initialize packet-based, real-time trace PAD generator with scaling"""
        super(PadGenerator, self).__init__(showWarnings)
        self.show_warnings = showWarnings
        self.maxsec_rttrace = maxsec_rttrace # in seconds for EACH (x,y,z) rt_trace
        self.scale_factor = scale_factor
        if showWarnings:
            self.warnfiltstr = 'always'
        else:
            self.warnfiltstr = 'ignore'

    def __str__(self):
        #s = ''
        #for k,v in self.__dict__.iteritems():
        #    s += '%25s: %s\n' % (k, str(v))
        #return s
        if self.lastPacket:
            return 'lastPacket.endTime()=%s' % unix2dtm( self.lastPacket.endTime() )
        else:
            return 'HEY...lastPacket is %s' % str(self.lastPacket)

    # one_shot as class method
    def next(self, step_callback=None):
        global MAX_RESULTS, MAX_RESULTS_PER_TABLE
        #BENCH_NEXT_METHOD.start()
        log.debug('%04d ONESH inspect=%s %s' % (get_line(), PARAMETERS['inspect'], '-' * 99))
        self.lastPacketTotal = TOTAL_PACKETS_FED
        self.moreToDo = 0
        timeNow = time()
        cutoffTime = timeNow - max(PARAMETERS['cutoffDelay'], MIN_DELAY)
        if PARAMETERS['endTime'] > 0.0:
            cutoffTime = min(cutoffTime, PARAMETERS['endTime'])
    
        # verify host has table we want
        tables = []
        for table in sqlConnect('show tables',
                         shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database']):
            tableName = table[0]
            columns = []
            for col in sqlConnect('show columns from %s' % tableName,
                           shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database']):
                columns.append(col[0])
            if ('time' in columns) and ('packet' in columns):
                tables.append(tableName)
        if PARAMETERS['tables'] != 'ALL':
            wanted = split(PARAMETERS['tables'], ',')
            newTables = []
            for w in wanted:
                if w in tables:
                    newTables.append(w)
                else:
                    t = UnixToHumanTime(time(), 1)
                    t = t + ' warning: table %s was not found, ignoring it' % w
                    print_log(t)
            tables = newTables
        else:
            msg = 'This program does NOT handle "ALL" or comma-delimited for tables parameter (Ted legacy NOT supported).'
            log.error(msg)
            raise Exception(msg)
        # here's where we check for one and only one table of interest on host
        if len(tables) != 1:
            msg = 'did not find exactly one table for %s on host %s' % (PARAMETERS['tables'], PARAMETERS['host'])
            log.error(msg)
            raise Exception(msg)
        
        tableName = tables[0]
        if idleWait(0):
            msg = 'idleWait(0) returned True, this is where packetWriter.py would itself exit.'
            log.error(msg)
            raise Exception(msg)

        ############################################
        # get key info for processing packets here #
        ############################################
        update_anc_databases()
        preCutoffProgress = 0
        packetCount = 0
        start = ceil4(max(self.lastTime(), PARAMETERS['startTime'])) # database has only 4 decimals of precision
        
        # write all packets before cutoffTime
        tpResults = get_tp_query_results(tableName, start, cutoffTime, MAX_RESULTS, (get_line(), 'write all pkts before cutoffTime'))
        packetCount = packetCount + len(tpResults)
        while len(tpResults) != 0:
            for result in tpResults:
                p = guessPacket(result[1], showWarnings=1)
                if p.type == 'unknown':
                    log.warning('unknown packet type at time %.4lf' % result[0])
                    continue
                log.debug('%04d one_shot() table=%7s ptype=%s r[0]=%.4f pcontig=%s' %(get_line(), tableName, p.type, result[0], p.contiguous(self.lastPacket)))
                preCutoffProgress = 1                        
                self.writePacket(p)
                
            if packetCount >= MAX_RESULTS_PER_TABLE or len(tpResults) != MAX_RESULTS or idleWait(0):
                if packetCount >= MAX_RESULTS_PER_TABLE:
                    self.moreToDo = 1 # go work on another table for a while
                self.end()
                tpResults = []
            else:
                start = ceil4(max(self.lastTime(), PARAMETERS['startTime'])) # database has only 4 decimals of precision
                tpResults = get_tp_query_results(tableName, start, cutoffTime, MAX_RESULTS, (get_line(), 'while more tpResults exist, query new start and new cutoffTime'))
                packetCount = packetCount + len(tpResults)

        log.debug('%04d one_shot() finished BEFORE-cutoff packets for %s up to %.6f, moreToDo:%s' % (get_line(), tableName, self.lastTime(), self.moreToDo))
            
        # write contiguous packets after cutoffTime
        if preCutoffProgress and not self.moreToDo:
            packetCount = 0
            stillContiguous = 1
            maxTime = timeNow-MIN_DELAY
            if PARAMETERS['endTime'] > 0.0:
                maxTime = min(maxTime, PARAMETERS['endTime'])
            if PARAMETERS['endTime'] == 0.0 or maxTime < PARAMETERS['endTime']:
                tpResults = get_tp_query_results(tableName, ceil4(self.lastTime()), maxTime, MAX_RESULTS, (get_line(), 'write contiguous pkts after cutoffTime'))
                packetCount = packetCount + len(tpResults)
                while stillContiguous and len(tpResults) != 0 and not idleWait(0):
                    for result in tpResults:
                        p = guessPacket(result[1])
                        if p.type == 'unknown':
                            continue
                        log.debug('%04d one_shot() table=%7s ptype=%s r[0]=%.4f pcontig=%s' %(get_line(), tableName, p.type, result[0], p.contiguous(self.lastPacket)))
                        stillContiguous = p.contiguous(self.lastPacket)
                        if not stillContiguous:
                            break
                        self.writePacket(p, stillContiguous)
                    if packetCount >= MAX_RESULTS_PER_TABLE or len(tpResults) != MAX_RESULTS:
                        if packetCount >= MAX_RESULTS_PER_TABLE:
                            self.moreToDo = 1 # go work on another table for a while
                        self.end()
                        tpResults = []
                    elif stillContiguous:
                        tpResults = get_tp_query_results(tableName, ceil4(self.lastTime()), maxTime, MAX_RESULTS, (get_line(), 'while still contiguous and more tpResults...'))
                        packetCount = packetCount + len(tpResults)
                    else:
                        tpResults = []

        log.debug('%04d one_shot() finished AFTER-cutoff CONTIGUOUS packets for %s up to %.6f, moreToDo:%s' % (get_line(), tableName, self.lastTime(), self.moreToDo))

        self.end()
        dispose_processed_data(tableName, self.lastTime())

        if step_callback:
            current_info_tuple = ('%s' % unix2dtm(self.lastPacket.time()), '%s' % unix2dtm(self.lastPacket.endTime()), '%d' % self.moreToDo)
            cumulative_info_tuple = ('%s' % unix2dtm(self.lastPacket.time()), '%s' % unix2dtm(self.lastPacket.endTime()), '%d' % TOTAL_PACKETS_FED)
            step_callback(current_info_tuple, cumulative_info_tuple)
        
        #log.debug('%04d %s' % (get_line(), BENCH_NEXT_METHOD))
        
        # Only the initial "next" uses MAX_RESULTS_PER_TABLE, thereafter we use MAX_RESULTS
        MAX_RESULTS_PER_TABLE = MAX_RESULTS
        
        return TOTAL_PACKETS_FED

    def init_realtime_trace_registerproc(self, hdr, ax):
        """initialize real-time traces and register process for scale-factor"""
        # set max length (in sec) for real-time trace during init to avoid memory issue
        rt_trace = PimsRtTrace(max_length=self.maxsec_rttrace)
        
        # data nominally in g, but most likely mg or ug preferred
        rt_trace.registerRtProcess('scale', factor=self.scale_factor)

        # use Ted's legacy XML header info to our advantage for real-time trace
        rt_trace.stats['network'] = hdr['System']
        rt_trace.stats['station'] = hdr['SensorID']
        rt_trace.stats['sampling_rate'] = hdr['SampleRate']
        rt_trace.stats['location'] = hdr['SensorCoordinateSystem']['comment']
        rt_trace.stats['channel'] = ax

        return rt_trace

    def append_process_packet_data(self, atxyzs, start, contig):
        """append and auto-process packet data into PimsRtTrace"""
        # FIXME should we use MERGE method here or somewhere (NaN fill?)
        if contig:
            log.debug( 'RTAPPEND:..lastPacket.endTime()=%s' % unix2dtm(self.lastPacket.endTime()) )
            log.debug( 'RTAPPEND:thisPacket.startTime()=%s, delta=%0.6f' % (unix2dtm(start), start-self.lastPacket.endTime()))
            for i, ax in enumerate(['x', 'y', 'z']):
                tr = self.as_trace( atxyzs[:, i+1] )
                tr.stats.starttime = self.lastPacket.endTime() + self.rt_trace[ax].stats.delta
                self.rt_trace[ax].append( tr, gap_overlap_check=False, verbose=self.show_warnings) # FIXME should this be True (throws error) or pre-nudge?
        else:
            log.warning('%04d DROPPED A PACKET; unhandled case when non-contiguous, although rt_trace with good merge might work%s' % (get_line(), '?'*40))
        log.debug( "%s" % str(self.rt_trace['x']))

    def as_trace(self, data):
        return Trace( data=data, header=self.rt_trace['x'].stats )

    # get header subfields
    def get_subfields(self, h, field, Lsubs):
        """get sub fields using xml parser"""
        d = {}	
        for k in Lsubs:
            theElement = h.documentElement.getElementsByTagName(field)[0]
            d[k] = str(theElement.getAttribute(k))
        return d

    # get first header
    def get_first_header(self):
        """get first header (only first)"""
        dHeader = {}
        h = xml_parse( self.buildHeader('NOFILE') )
        
        # get XML root node localName (like "sams2_accel") and split for system
        dHeader['System'] = h.documentElement.localName.split('_')[0].upper()
        
        # get a few basic fields
        L = ['SampleRate', 'CutoffFreq', 'DataQualityMeasure', 'SensorID', 'TimeZero', 'ISSConfiguration']
        for i in L:
            dHeader[i] = str(h.documentElement.getElementsByTagName(i)[0].childNodes[0].nodeValue)
        dHeader['SampleRate'] = float(dHeader['SampleRate'])
        dHeader['CutoffFreq'] = float(dHeader['CutoffFreq'])
        
        # get fields that have sub-fields
        Lcoord = ['x','y','z','r','p','w','name','time','comment']
        dHeader['SensorCoordinateSystem'] = self.get_subfields(h,'SensorCoordinateSystem',Lcoord)
        dHeader['DataCoordinateSystem'] = self.get_subfields(h,'DataCoordinateSystem',Lcoord)
        dHeader['GData'] = self.get_subfields(h,'GData',['format','file'])
        
        # use first header as self.header_string
        self.header_string = '%s, %s (%g Hz, %g sps), at %s in %s Coordinates' % (
            dHeader['System'],
            dHeader['SensorID'],
            dHeader['CutoffFreq'],
            dHeader['SampleRate'],
            dHeader['SensorCoordinateSystem']['comment'],
            dHeader['DataCoordinateSystem']['name'])
        
        # initialize real-time trace and register real-time process (scale factor)
        self.rt_trace = {}
        for ax in ['x', 'y', 'z']:
            self.rt_trace[ax] = self.init_realtime_trace_registerproc(dHeader, ax)

    # primative comparison of packet header info to first, lead header counterparts
    def is_header_same(self, p):
        """compare packet header info to first header"""
        if self.rt_trace['x'].stats['station'] == p.name():              # like "121f05" or maybe "hirap"
            if self.rt_trace['x'].stats['sampling_rate'] == p.rate():    # a float like say 500.0
                return True
        return False

    # formatted string of bool; True if this packet is contiguous with last packet"""
    def show_contig(self, lastp, thisp):
        """formatted string of bool; True if this packet is contiguous with last packet"""
        if not lastp:
            bln = 'XXXXX'
        else:
            bln = thisp.contiguous(lastp)
        return "contig={0:<5s}".format( str(bln) )
    
    # append data, per-axis each to rt_trace
    def append(self, packet):
        """append data, per-axis each to rt_trace"""
        global TOTAL_PACKETS_FED
        
        log.debug( '%04d %s BEFOR append() %s' % (get_line(), str(self), self.show_contig(self.lastPacket, packet)) )
        
        # FIXME what happens if we get rid of this thru the BytesIO part?
        if self._file_ == None:
            newName = 'temp.' + packet.name()
            #os.system('rm -rf %s.header' % self._fileName_)
            ok = True #os.system('mv %s %s' % (self._fileName_, newName)) == 0
            log.debug('%04d append() is NOT REALLY moving %s to %s, success:%s' % (get_line(), self._fileName_, newName, ok))
            if not ok: # move failed, maybe file doesn't exist anymore
                contiguous = packet.contiguous(self.lastPacket)
                if contiguous:
                    self._fileSep = '+'
                else:
                    self._fileSep = '-'
                self._fileStart_ = packet.time()
            self._fileName_ = newName
            #self._file_ = open(self._fileName_, 'ab') # this is okay, giving zero-length file
            self._file_ = BytesIO(self._fileName_) # FIXME w/o this or line above we run slow

        txyzs = packet.txyz()
        packetStart = packet.time()
        atxyzs = np.array(txyzs, np.float32)
        if  self._rotateData_ and 4 == len(atxyzs[0]):  # do coordinate system rotation
            atxyzs[:,1:] = np.dot(atxyzs[:,1:], self._rotationMatrix_ )
        atxyzs[:,0] = atxyzs[:,0] + np.array(packetStart-self._fileStart_, np.float32) # add offset to times

        aextra = None
        extra = packet.extraColumns()
        if extra:
            aextra = np.array(extra, np.float32)

        if not PARAMETERS['ascii']:
            if PARAMETERS['bigEndian']:
                atxyzs = atxyzs.byteswap() 
                if extra:
                    aextra = aextra.byteswap()
            if extra:
                atxyzs = concatenate((atxyzs, aextra), 1)
            #self._file_.write(atxyzs.tostring()) # NOTE THIS IS "NOT-WRITING" JUST INSPECTING
            #print atxyzs
        else:
            s= ''
            if extra:
                atxyzs = concatenate((atxyzs, aextra), 1)
            formatString = '%.4f'
            for col in atxyzs[0][1:]:
                formatString = formatString + ' %.7e'
            formatString = formatString + '\n'
            for row in atxyzs:
                s = s + formatString % tuple(row)
            #self._file_.write(s) # NOTE THIS IS "NOT-WRITING" JUST INSPECTING

        # for very first packet, get header info
        if TOTAL_PACKETS_FED == 0:
            self.get_first_header()

        # append and auto-process packet data into PimsRtTrace:
        if self.is_header_same(packet):
            with warnings.catch_warnings(): #self.warnfiltstr
                warnings.filterwarnings(self.warnfiltstr, '.*RtTrace.*|Gap of.*|Overlap of.*')
                self.append_process_packet_data(atxyzs, packetStart, packet.contiguous(self.lastPacket))
        else:
            log.warning( 'DO NOT APPEND PACKET because we got False from is_header_same (near line %d)' % get_line() )
        
        # update lastPacket and TOTAL_PACKETS_FED
        self.lastPacket = packet
        TOTAL_PACKETS_FED = TOTAL_PACKETS_FED + 1
        
        log.debug( '%04d %s AFTER append() %s' % (get_line(), str(self), self.show_contig(self.lastPacket, packet)) )

# return sensor and data coordinate system database entries, if they exist
def check_coord_sys(dataTime, sensor, dataName):
    if not ANC_DATA.has_key('coord_system_db'):
        t =  UnixToHumanTime(time(), 1)
        t = t + ' warning: data coordinate system "%s" requested, but "coord_system_db" was not found' % dataName
        print_log(t)
        return (0, 0) # coordinate system database doesn't exit
    csdb = ANC_DATA['coord_system_db']
    sensorEntry = None
    dataEntry = None
    for i in csdb:
        if i[0] > dataTime:
            break
        eName = string.lower(string.strip(i[1]))
        if eName == sensor:
            sensorEntry = i
        if eName == dataName:
            dataEntry = i
    if sensorEntry and dataEntry:
        return (sensorEntry, dataEntry)
    else: 
        t = UnixToHumanTime(time(), 1)
        t = t + ' warning: data coordinate system "%s" requested, but "coord_system_db"\n' % dataName
        t = t + '  did not have entries for %s and %s before time %.4f' % (sensor, dataName, dataTime)
        print_log(t)
        return (0, 0) # didn't find coordinate systems entries for both sensor and data
    
# format an ancillary data entry in XML       
def add_anc_xml(db, entry, dataTime, sensor, pf, dbMatchTime): 
    global ANC_XML
    newLine = ''
    if db == 'bias':
        newLine = '\t<BiasCoeff x="%s" y="%s" z="%s"/>\n' % entry
    elif db == 'scale':
        newLine = '\t<ScaleFactor x="%s" y="%s" z="%s"/>\n' % entry
    elif db == 'dqm':
        newLine = '\t<DataQualityMeasure>%s</DataQualityMeasure>\n' % xmlEscape(string.strip(entry[0]))
    elif db == 'iss_config':
        newLine = '\t<ISSConfiguration>%s</ISSConfiguration>\n' % xmlEscape(string.strip(entry[0]))
    elif db == 'coord_system_db':
        newLine = '\t<SensorCoordinateSystem name="%s" ' % sensor
        newLine = newLine + 'r="%s" p="%s" w="%s" x="%s" y="%s" z="%s" comment="%s" ' % entry
        newLine = newLine + 'time="%s"/>\n' % UnixToHumanTime(dbMatchTime)
    elif db == 'data_coord_system':
        dataName = string.lower(string.strip(entry[0]))
        if pf.setDataCoordSystem(dataName, dataTime, sensor): 
            newLine = '\t<DataCoordinateSystem name="%s" ' % string.strip(entry[0])
            # lookup data coord system info
            sensorEntry, dataEntry = check_coord_sys(dataTime, sensor, dataName)
            newLine = newLine + 'r="%s" p="%s" w="%s" x="%s" y="%s" z="%s" ' % dataEntry[2:-1]
            newLine = newLine + 'comment="%s" ' % xmlEscape(dataEntry[-1])
            newLine = newLine + 'time="%s"/>\n' % UnixToHumanTime(dataEntry[0])
        else: # coord system lookup failed, use sensor coordinates
            newLine = '\t<DataCoordinateSystem name="sensor"/>\n' 
    ANC_XML = ANC_XML + newLine
    
# look for valid ancillary data entries for a given sensor and time    
def update_anc_xml(dataTime, sensor, pf): 
    global ANC_XML
    ANC_XML = ''
    adKeys = ANC_DATA.keys()
    adKeys.sort() # always process databases in the same order
    for i in adKeys:
        ad = ANC_DATA[i]
        format = ANC_DATA_FORMAT[i]
        maxTime = 0
        for j in ad:
            colName = string.lower(format[1][0])
            if colName == 'sensor' or colName == 'coord_name':
                if sensor != string.lower(j[1]):
                    continue
                if j[0] >= maxTime and j[0] < dataTime:
                    maxTime, entry  = j[0], j[2:]
                else:
                    break
            else:             
                if j[0] >= maxTime and j[0] < dataTime:
                    maxTime, entry  = j[0], j[1:]
                else:
                    break
        if maxTime != 0: # we have a good entry
            add_anc_xml(i, entry, dataTime, sensor, pf, maxTime)

# rebuild all ancillary data for this sensor, if the time is right
def update_anc_data(dataTime, sensor, pf):
    global ANC_UPDATE, ANC_XML
    if dataTime < ANC_UPDATE:
        return
    else:
        oldAncillaryXML = ANC_XML
        sensor = string.lower(sensor)
        update_anc_xml(dataTime, sensor, pf) # update headers
        if oldAncillaryXML != ANC_XML:
            pf._forceNewFile_ = 1
            # must end old pad file with oldAncillaryXML before using new ANC_XML
            saveXML = ANC_XML
            ANC_XML = oldAncillaryXML
            pf.end()
            ANC_XML = saveXML
        # find next scheduled ancillary change 
        maxUpdate = time()
        newUpdate = maxUpdate
        for i in ANC_DATA.keys():
            ad = ANC_DATA[i]
            for j in ad:
                if j[0] > dataTime and j[0] < newUpdate:
                    newUpdate = j[0]
                    break
        if newUpdate != maxUpdate:
            ANC_UPDATE = newUpdate
        else: # no need to check for any more updates
            ANC_UPDATE = time() + 10000000 # don't update at all until database changes
##        print 'next ancillary data update after %s scheduled for %s' % (dataTime, ANC_UPDATE)

# retrieve the ancillary databases
def update_anc_databases():
    global ANC_UPDATE, ANC_DATA
    if PARAMETERS['ancillaryHost'] == 'None':
        ANC_UPDATE = time() + 10000000 # don't update at all
        return
    try: 
        for db in ANC_DATABASES:
            ANC_DATA[db] = sqlConnect('select * from %s order by time' % db,
                 shost=PARAMETERS['ancillaryHost'], suser=UNAME, spasswd=PASSWD, sdb='pad')
            ANC_DATA_FORMAT[db] = sqlConnect('show columns from %s' % db,
                 shost=PARAMETERS['ancillaryHost'], suser=UNAME, spasswd=PASSWD, sdb='pad')
        ANC_UPDATE = 0 # database may have changed, need to rebuild ancillary data
##        # dump databases for debugging
##        for i in ANC_DATA.keys():
##            ad = ANC_DATA[i]
##            print '%s:' % i
##            for j in ad:
##                print j
    except OperationalError, value:
        t = UnixToHumanTime(time(), 1)
        t = t + ' ancillary database error %s' % value
        print_log(t)
        sys.exit()

# dispose of processed data
def dispose_processed_data(tableName, lastTime):
    global PACKETS_WRITTEN
    if PARAMETERS['startTime'] > 0.0:
        minTime = PARAMETERS['startTime']
    else:
        minTime = -10000000.0 # should be negative infinity
    if PARAMETERS['delete']=='0':
        return

    # make sure the number of packets to be deleted is not less than the number written
    deleted = sqlConnect('select time from %s where time <= %.6lf and time > %.6lf' % (tableName, ceil4(lastTime), minTime),shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database'])
    
    packetsWrittenCheck = PACKETS_WRITTEN
    PACKETS_WRITTEN = 0

    if PARAMETERS['delete']=='1': # delete processed packets here
        sqlConnect('delete from %s where time <= %.6lf and time > %.6lf' % (tableName, ceil4(lastTime), minTime),
            shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database'])
    else: # move data to new database instead of deleting
        newTable = PARAMETERS['delete']
        # see if table exists
        tb = sqlConnect('show tables',
            shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database'])
        for i in tb:
            if i[0] == newTable:
                break
        else: # newTable not found, must create it 
            key = '' # check if we need a primary key
            col = sqlConnect('show columns from %s' % tableName,         
                 shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database'])
            for c in col:
                if c[0]=='time' and c[3]=='PRI':
                    key = 'PRIMARY KEY'
            sqlConnect('CREATE TABLE %s(time DOUBLE NOT NULL %s, packet BLOB NOT NULL, type INTEGER NOT NULL, header BLOB NOT NULL)' % (newTable, key),
                 shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database'])
        sqlConnect('insert into %s select * from %s where time <= %.6lf and time > %.6lf' % (newTable,tableName,ceil4(lastTime), minTime),
            shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database'])
        sqlConnect('delete from %s where time <= %.6lf and time > %.6lf' % (tableName, ceil4(lastTime), minTime),
            shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database'])
        
    if packetsWrittenCheck > len(deleted): # we should throw an exception here, but generate a warning instead
        print 'WARNING: more packets were written then are being deleted'
        print 'This might mean there are extra packets in the PAD file, skewing data after this point'
        print 'Wrote %s packets to PAD file, but deleting only %s from database' % (packetsWrittenCheck, len(deleted))
        
        # try to determine where the packet not getting deleted is occuring
        around = sqlConnect('select time from %s where time <= %.6lf and time > %.6lf' % (tableName, ceil4(lastTime)+5,ceil4(lastTime)-5 ),shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database'])
        # print out times within plus/minus 5 seconds of lastTime
        print 'The problem occurred writing and deleting packets in database time <= %.6lf' % ceil4(lastTime)
        print 'The next packet in the database to be processed is at time %.6lf' % around[0] # assumes that around will be after lastTime

# get time,packet results from db table with a limit on number of results
def get_tp_query_results(table, ustart, ustop, lim, tuplabel):
    """get time,packet results from db table with set limit"""
    querystr = 'select time,packet from %s where time > %.6f and time < %.6f order by time limit %d' % (table, ustart, ustop, lim)
    #print querystr
    #print 'select time,packet from %s where time > "%s" and time < "%s" order by time limit %d' % (table, unix2dtm(ustart), unix2dtm(ustop), lim)
    log.info('%04d QUERY %s < time < %s FROM %s LIMIT %d %s' % (tuplabel[0], unix2dtm(ustart), unix2dtm(ustop), table, lim, tuplabel[1]))
    tpResults = sqlConnect(querystr, shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database'])
    return tpResults

# one iteration of main_loop
def one_shot(pfs):
    global moreToDo, lastPacketTotal, log
    log.debug('%04d PACKETS_WRITTEN = %04d, TOTAL_PACKETS_FED = %04d @ top of one_shot' % (get_line(), PACKETS_WRITTEN, TOTAL_PACKETS_FED))
    log.debug('%04d ONESH inspect=%s %s' % (get_line(), PARAMETERS['inspect'], '-' * 99))
    lastPacketTotal = TOTAL_PACKETS_FED
    moreToDo = 0
    timeNow = time()
    cutoffTime = timeNow - max(PARAMETERS['cutoffDelay'], MIN_DELAY)
    if PARAMETERS['endTime'] > 0.0:
        cutoffTime = min(cutoffTime, PARAMETERS['endTime'])

    # build list of tables to work with
    tables = []
    for table in sqlConnect('show tables',
                     shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database']):
        tableName = table[0]
        columns = []
        for col in sqlConnect('show columns from %s' % tableName,
                       shost=PARAMETERS['host'], suser=UNAME, spasswd=PASSWD, sdb=PARAMETERS['database']):
            columns.append(col[0])
        if ('time' in columns) and ('packet' in columns):
            tables.append(tableName)
    if PARAMETERS['tables'] != 'ALL':
        wanted = split(PARAMETERS['tables'], ',')
        newTables = []
        for w in wanted:
            if w in tables:
                newTables.append(w)
            else:
                t = UnixToHumanTime(time(), 1)
                t = t + ' warning: table %s was not found, ignoring it' % w
                print_log(t)
        tables = newTables
    else:
        msg = 'This program does NOT handle "ALL" or comma-delimited for tables parameter (Ted legacy NOT supported).'
        log.error(msg)
        raise Exception(msg)
    
    for tableName in tables:
        if idleWait(0):
            break # check for shutdown in progress

        #########################################################
        # initialize PadGenerator or PacketInspector class here #
        #########################################################              
        update_anc_databases()
        preCutoffProgress = 0
        packetCount = 0
        if not pfs.has_key(tableName):
            if PARAMETERS['inspect'] == 2:
                pf = PadGenerator(
                    showWarnings=PARAMETERS['showWarnings'],
                    maxsec_rttrace=PARAMETERS['maxsec_rttrace'],
                    scale_factor=PARAMETERS['scale_factor'],
                    )
            elif PARAMETERS['inspect'] == 1:
                pf = PacketInspector(PARAMETERS['showWarnings'])
            else:
                pf = PacketFeeder(PARAMETERS['showWarnings'])
            log.info('%s starting...' % pf.__class__.__name__)
            pfs[tableName] = pf
        else:
            pf = pfs[tableName]
        start = ceil4(max(pf.lastTime(), PARAMETERS['startTime'])) # database has only 4 decimals of precision
        
        # write all packets before cutoffTime
        tpResults = get_tp_query_results(tableName, start, cutoffTime, MAX_RESULTS, (get_line(), 'write all pkts before cutoffTime'))
        packetCount = packetCount + len(tpResults)
        while len(tpResults) != 0:
            for result in tpResults:
                p = guessPacket(result[1], showWarnings=1)
                if p.type == 'unknown':
                    print_log('unknown packet type at time %.4lf' % result[0])
                    continue
                log.debug('%04d one_shot() table=%7s ptype=%s r[0]=%.4f pcontig=%s' %(get_line(), tableName, p.type, result[0], p.contiguous(pf.lastPacket)))
                preCutoffProgress = 1                        
                pf.writePacket(p)
                
            if packetCount >= MAX_RESULTS_PER_TABLE or len(tpResults) != MAX_RESULTS or idleWait(0):
                if packetCount >= MAX_RESULTS_PER_TABLE:
                    moreToDo = 1 # go work on another table for a while
                pf.end()
                tpResults = []
            else:
                start = ceil4(max(pf.lastTime(), PARAMETERS['startTime'])) # database has only 4 decimals of precision
                tpResults = get_tp_query_results(tableName, start, cutoffTime, MAX_RESULTS, (get_line(), 'while more tpResults exist, query new start and new cutoffTime'))
                packetCount = packetCount + len(tpResults)

        log.debug('%04d one_shot() finished BEFORE-cutoff packets for %s up to %.6f, moreToDo:%s' % (get_line(), tableName, pf.lastTime(), moreToDo))
            
        # write contiguous packets after cutoffTime
        if preCutoffProgress and not moreToDo:
            packetCount = 0
            stillContiguous = 1
            maxTime = timeNow-MIN_DELAY
            if PARAMETERS['endTime'] > 0.0:
                maxTime = min(maxTime, PARAMETERS['endTime'])
            if PARAMETERS['endTime'] == 0.0 or maxTime < PARAMETERS['endTime']:
                tpResults = get_tp_query_results(tableName, ceil4(pf.lastTime()), maxTime, MAX_RESULTS, (get_line(), 'write contiguous pkts after cutoffTime'))
                packetCount = packetCount + len(tpResults)
                while stillContiguous and len(tpResults) != 0 and not idleWait(0):
                    for result in tpResults:
                        p = guessPacket(result[1])
                        if p.type == 'unknown':
                            continue
                        log.debug('%04d one_shot() table=%7s ptype=%s r[0]=%.4f pcontig=%s' %(get_line(), tableName, p.type, result[0], p.contiguous(pf.lastPacket)))
                        stillContiguous = p.contiguous(pf.lastPacket)
                        if not stillContiguous:
                            break
                        pf.writePacket(p, stillContiguous)
                    if packetCount >= MAX_RESULTS_PER_TABLE or len(tpResults) != MAX_RESULTS:
                        if packetCount >= MAX_RESULTS_PER_TABLE:
                            moreToDo = 1 # go work on another table for a while
                        pf.end()
                        tpResults = []
                    elif stillContiguous:
                        tpResults = get_tp_query_results(tableName, ceil4(pf.lastTime()), maxTime, MAX_RESULTS, (get_line(), 'while still contiguous and more tpResults...'))
                        packetCount = packetCount + len(tpResults)
                    else:
                        tpResults = []

        log.debug('%04d one_shot() finished AFTER-cutoff CONTIGUOUS packets for %s up to %.6f, moreToDo:%s' % (get_line(), tableName, pf.lastTime(), moreToDo))

        pf.end()
        dispose_processed_data(tableName, pf.lastTime())

    log.debug('%04d PACKETS_WRITTEN = %04d, TOTAL_PACKETS_FED = %04d @ bottom of one_shot' % (get_line(), PACKETS_WRITTEN, TOTAL_PACKETS_FED))

# main packet writing loop
def main_loop():
    global moreToDo, lastPacketTotal, log
    pfs = {}

    # we do not handle "ALL" tables or comma-separated list of tables
    if ('ALL' in PARAMETERS['tables']) or (',' in PARAMETERS['tables']):
        msg = 'we do not handle "ALL" or comma-separated for tables parameter (Ted legacy not supported)'
        log.error(msg)
        raise Exception(msg)
    try:
        while 1: # until killed or ctrl-C or no more data (if PARAMETERS['quitWhenDone'])
            
            # perform one iteration of main loop (get/process packets)
            one_shot(pfs)
            
            if not moreToDo:
                log.info("%04d NORES TOTAL_PACKETS_FED=%d moreToDo=%d now=%s checkEverySec=%d" % (get_line(), TOTAL_PACKETS_FED, moreToDo, datetime.datetime.now(), SLEEP_TIME))
                if lastPacketTotal == TOTAL_PACKETS_FED and PARAMETERS['quitWhenDone']:
                    break # quit main_loop() and exit the program
                if idleWait(SLEEP_TIME):
                    break # quit main_loop() and exit the program
            else:
                if idleWait(0):
                    break # quit main_loop() and exit the program

    finally:
        if BENCH_COUNT > 0:
            print 'benchmark average: %.6f' % (BENCH_TOTAL/BENCH_COUNT)
        # finalize any open files
        for k in pfs.keys():
            dataFileName = pfs[k].end()
            if  pfs[k]._maybeMove_ != '':
                pfs[k].movePadFile(pfs[k]._maybeMove_)
                
        # FIXME we IGNORE packetFeederState file
        if False:
            file = open('packetFeederState', 'wb')
            pickle.dump(pfs, file)
            file.close()

# convert startTime from string to unixtime float
def atof_unixstart(s):
    global _HOSTNAME
    f = atof(s)
    if f >= 0.0:
        return f
    
    # negative value for startTime signals "good" startTime
    _HOSTNAME = socket.gethostname()
    if _HOSTNAME == 'park':
        return 1378741399.5 # for debug and testing
    else:
        # timeNow minus plot_buffer, which is rt_params['time.maxsec_trace']
        timeNow = time()
        return timeNow - rt_params['time.maxsec_trace']

def custom_warn(message, category, filename, lineno, file=None, line=None):
    log.warning(warnings.formatwarning(message, category, filename, lineno).replace('\n',' '))

# check PARAMETERS
def parameters_ok():
    """check PARAMETERS and possibly change rt_params"""
# FIXME scrub this for better approach with testing to verify end items
    global log
    
    # Start log; refer to rt_params for log verbose level
    b = rt_params['verbose.level'].upper()
    if b != 'DEBUG' and b != 'INFO' and b != 'WARNING' and b != 'ERROR' and b != 'CRITICAL' :
        print " rt_params['verbose.level'] must be debug or info or warning or error or critical"
        return 0
    else:
        rt_params['verbose.level'] = b
        log = SimpleLog('pims_pad_packetfeeder', log_level=b).log
        log.info('Logging started.')
        
    warnings.showwarning = custom_warn
    warnings.warn("Stray warnings are being put into log via custom_warn function.")

    b = PARAMETERS['inspect']
    if b != '0' and b != '1' and b != '2':
        log.error(' inspect must be 0 or 1 (or 2)')
        return 0
    else:
        PARAMETERS['inspect'] = rt_params['pw.inspect'] =  atoi(b)

    b = PARAMETERS['resume']
    if b != '0' and b != '1':
        log.error(' resume must be 0 or 1')
        return 0
    else:
        PARAMETERS['resume'] = rt_params['pw.resume'] = atoi(b)

    b = PARAMETERS['showWarnings']
    if b != '0' and b != '1':
        log.error(' showWarnings must be 0 or 1')
        return 0
    else:
        rt_params['pw.showWarnings'] = PARAMETERS['showWarnings'] = atoi(b)

    b = PARAMETERS['ascii']
    if b != '0' and b != '1':
        log.error(' ascii must be 0 or 1')
        return 0
    else:
        PARAMETERS['ascii'] = rt_params['pw.ascii'] = atoi(b)
        
    b = PARAMETERS['quitWhenDone']
    if b != '0' and b != '1':
        log.error(' quitWhenDone must be 0 or 1')
        return 0
    else:
        PARAMETERS['quitWhenDone'] = rt_params['pw.quitWhenDone'] = atoi(b)
        
    b = PARAMETERS['bigEndian']
    if b != '0' and b != '1':
        log.error(' bigEndian must be 0 or 1')
        return 0
    else:
        PARAMETERS['bigEndian'] = rt_params['pw.bigEndian'] = atoi(b)

    b = PARAMETERS['delete']
    if b != '0' and b != '1':
        log.error(' delete must be 0 or 1')
        return 0
    else:
        PARAMETERS['delete'] = rt_params['pw.delete'] = b
    
    b = PARAMETERS['tables']
    if PARAMETERS['tables']=='ALL' or len(split(PARAMETERS['tables'], ',')) != 1:
        log.error(' you must specify only 1 table with "tables="')
        return 0
    else:
        PARAMETERS['tables'] = rt_params['pw.tables'] = b        

    b = PARAMETERS['additionalHeader']
    if b != '\"\"':
        b = string.replace(b, '#', ' ')      # replace hash marks with spaces
        b = string.replace(b, '~~', chr(10)) # replace double tilde with carriage returns
        b = string.replace(b, '~', chr(9))   # replace single tilde with tab
        PARAMETERS['additionalHeader'] = rt_params['pw.additionalHeader'] = b

    PARAMETERS['startTime'] = rt_params['pw.startTime'] = atof_unixstart(PARAMETERS['startTime'])
    PARAMETERS['endTime'] = rt_params['pw.endTime'] = atof(PARAMETERS['endTime'])
    PARAMETERS['cutoffDelay'] = rt_params['pw.cutoffDelay'] = atof(PARAMETERS['cutoffDelay'])
    PARAMETERS['maxFileTime'] = rt_params['pw.maxFileTime'] = atof(PARAMETERS['maxFileTime'])

    rt_params['pw.ancillaryHost'] = PARAMETERS['ancillaryHost']
    rt_params['pw.host'] = PARAMETERS['host']
    rt_params['pw.database'] = PARAMETERS['database']

    b = PARAMETERS['destination']
    if b != '.':
        log.error(UnixToHumanTime(time(), 1) + ' testing scp connection...')
        dest = split(b, ':')
        if len(dest) != 2:
            log.error(' destination must be in ssh format: hostname:/directory/to/store/to')
            return 0
        host,directory = dest
        r = getoutput(" touch scptest;scp -p scptest %s" % (b))
        if len(r) != 0:
            log.error(' scp test failed')
            log.error(' host: %s, directory: %s, error: %s' % (host,directory,r))
            sys.exit()
        log.info(' scp OK')
        
    PARAMETERS['destination'] = rt_params['pw.destination'] = b

    if 0 == PARAMETERS['resume']:
        # remove any stale resume files
        getoutput('rm -rf packetFeederState temp.*')
    
    return 1

# print usage
def print_usage():
    print version
    print 'usage: PacketFeeder.py [options]'
    print '       options (and default values) are:'
    for i in DEFAULTS.keys():
        print '            %s=%s' % (i, DEFAULTS[i])

def demo_external_long_running(func, func_when_done, val=30):
    from time import sleep
    sleep(2)
    wx.CallAfter(func, val)
    sleep(2)
    wx.CallAfter(func, 2*val)
    sleep(1)
    wx.CallAfter(func, 3*val)
    sleep(3)
    wx.CallAfter(func_when_done)

class MainFrameForWxCallAfterDemo(wx.Frame):

    def __init__(self, parent, worker):
        wx.Frame.__init__(self, parent)

        self.worker = worker
        self.label = wx.StaticText(self, label="Ready")
        self.btn = wx.Button(self, label="Start")
        self.gauge = wx.Gauge(self)

        self.sizer = wx.BoxSizer(wx.VERTICAL)
        self.sizer.Add(self.label, proportion=1, flag=wx.EXPAND)
        self.sizer.Add(self.btn, proportion=0, flag=wx.EXPAND)
        self.sizer.Add(self.gauge, proportion=0, flag=wx.EXPAND)

        self.SetSizerAndFit(self.sizer)

        self.Bind(wx.EVT_BUTTON, self.on_button)

    def on_button(self, evt):
        self.btn.Enable(False)
        self.gauge.SetValue(0)
        self.label.SetLabel("Running")
        thread.start_new_thread( self.worker, (self.gauge.SetValue, self.on_long_run_done) )

    def on_long_run_done(self):
        self.gauge.SetValue(100)
        self.label.SetLabel("Done")
        self.btn.Enable(True)

def demo_wx_call_after(worker):
    app = wx.PySimpleApp()
    app.TopWindow = MainFrameForWxCallAfterDemo(None, worker)
    app.TopWindow.Show()
    app.MainLoop()

def demo_trace_header():
    import datetime
    hdr = {}
    hdr['network'] = 'SAMS'
    hdr['station'] = '121f05'
    hdr['location'] = 'LOCATION'
    hdr['channel'] = 'Xssa'
    hdr['sampling_rate'] = 500.0
    hdr['starttime'] = datetime.datetime.now()
    traces = []
    traces.append( Trace( np.array( range(500)), header=hdr ) )
    hdr['channel'] = 'Yssa'
    traces.append( Trace( np.array( range(500)), header=hdr ) )
    for tr in traces: print tr

def get_examplegen():
    """intialize/get example datagen"""
    from pims.gui.stripchart import DataGenExample
    return DataGenExample(scale_factor=0.01, num_splits=5)

def get_padgen():
    """intialize/get PAD datagen"""
    return PadGenerator(PARAMETERS['showWarnings'],
                        PARAMETERS['maxsec_rttrace'],
                        PARAMETERS['scale_factor'])

def launch_strip_chart(get_datagen, analysis_interval, plot_span, extra_intervals, title, maxpts):
    """launch the strip chart gui"""
    # preamble (packetfeeder.py main_loop code before first one_shot)
    global moreToDo, lastPacketTotal, log
    
    # initialize and get "datagen" object, whose next method gets most recent data
    datagen = get_datagen()

    # launch strip chart
    app = wx.PySimpleApp()
    app.frame = GraphFrame(datagen,
                           analysis_interval,
                           plot_span,
                           extra_intervals,
                           title,
                           maxpts) # maxlen for data deque used in stripchart
    app.frame.Show()
    app.MainLoop()

def callback_show(curr_info, cum_info):
    log.debug(curr_info)
    log.debug(cum_info)

def demo_pad_generator(num_iter=2):
    pg = PadGenerator()
    for x in range(num_iter):
        pg.next(step_callback=callback_show)
        log.debug( '%04d done with pg.next() #%d and TOTAL_PACKETS_FED = %d' % (get_line(), x+1, TOTAL_PACKETS_FED) )
        
def test_time_pad_generator(num_iter=2):
    from timeit import timeit
    sec = timeit("pg.next(step_callback=callback_show)", setup="from __main__ import callback_show, PadGenerator; pg = PadGenerator()", number=num_iter)
    print 'Average was %f seconds over %d iterations.  Total was %f seconds total' % ( sec / num_iter, num_iter, sec )

def dict_as_str(d):
    """show the dict sorted by keys as string with nice format"""
    s = ''
    keys = d.keys()
    keys.sort()
    maxlen = max(len(x) for x in keys)  # find max length
    fmt = '{0:<%ds} : {1:s}\n' % maxlen
    for k in keys:
        s += fmt.format( k, str(d[k]) )
    s += '=' * 78 + '\n'
    return s

def demo_strip():

    #for var in DEFAULTS_LIST:
    #    if PARAMETERS[var] == rt_params['pw.' + var]:
    #        print 'OK  ', var
    #    else:
    #        print 'BAD ', var
    #raise SystemExit

    #print '--- PARAMETERS %s\n' % ('-' * 55), dict_as_str(PARAMETERS)
    #print '--- rt_params %s\n' % ('-' * 55), dict_as_str(rt_params)
    #raise SystemExit

    #for k, v in zip(rt_params.keys(), rt_params.values()):
    #    print k, "%s" % v
    #raise SystemExit

    showWarnings = rt_params['pw.showWarnings']
    datagen = PadGenerator(showWarnings=showWarnings)
    app = wx.PySimpleApp()
    app.frame = GraphFrame(datagen, 'title', log, rt_params) # rt_params is from global namespace
    app.frame.Show()
    app.MainLoop()

# ~/dev/programs/python/packet/packetWriter.py tables=121f05 host=localhost ancillaryHost=localhost destination=. delete=0 cutoffDelay=0    
# e.g. python packetfeeder.py host=manbearpig tables=121f05 ancillaryHost=kyle startTime=1382551198.0 endTime=1382552398.0
# e.g. ON PARK packetfeeder.py tables=121f05 host=localhost ancillaryHost=None startTime=1378742112.0 inspect=1
# 25pkts e.g. PARK packetfeeder.py tables=121f05 host=localhost ancillaryHost=localhost startTime=1378742399.5 inspect=1
def run(func, *args, **kwargs):
    for p in sys.argv[1:]:  # parse command line
        pair = split(p, '=', 1)
        if (2 != len(pair)):
            print 'bad parameter: %s' % p
            break
        if not PARAMETERS.has_key(pair[0]):
            print 'bad parameter: %s' % pair[0]
            break
        else:
            PARAMETERS[pair[0]] = pair[1]
    else:
        if parameters_ok():
            # run func (e.g. main_loop, demo_padgen), then exit like packetWriter.py does
            func(*args, **kwargs)
            sys.exit(0)
    print_usage()
    
if __name__ == '__main__': 
    #run( main_loop )
    #run( test_time_pad_generator, num_iter=2 )
    run( demo_strip )