#!/usr/bin/env python
version = '$Id: packetWrangler.py,v 1.22 2004-11-29 20:00:04 pims Exp $'

# Adapted from Ted Wright's packetWriter.py

import os
import sys
import string 
import math
import pickle
import struct
import numpy as np
from time import *
from MySQLdb import *
from pims.realtime.accelpacket import *
from commands import *
from pims.utils.pimsdateutil import unix2dtm
from pims.kinematics.rotation import rotation_matrix
from pims.database.pimsquery import ceil4

DEBUGPRINT = False # for testing

# Absolute minimum time to leave data alone for it to settle and to allow other
# tasks to get access to it in the database (even if contiguous data is present after this)
minimumDelay = 10

# Wake up and process database every 20 seconds (this value is 30 *minutes* in packetWriter)
sleepTime = 20

# Max records in database request
maxResults = 100

# Max records to process before deleting processed data and/or working on another table for a while
maxResultsOneTable = 1000

# Packet counters
packetsWritten = 0
packetsDeleted = 0
totalPacketsWrangled = 0 # global variable for tracking if any progress is being made 

# set default command line parameters, times are always measured in seconds
defaults = { 'ancillaryHost':'kyle', # the name of the computer with the auxiliary databases (or 'None')
             'host':'localhost',        # the name of the computer with the database
             'database':'pims',         # the name of the database to process
             'tables':'ALL',            # the database tables that should be processed (separated by commas)
             'destination':'yoda:/sdds/pims/pub/pad', # the directory to write files into in scp format (host:/path/to/data)
             'delete':'0',              # 0=delete processed data, or 1=leave it in the database, or use
                                        #      databaseName to move it to different database
             'resume':'1',              # try to pick up where a previous run left off, or do whole database
             'inspect':'0',             # JUST INSPECT FOR UNEXPECTED CHANGES, DO NOT WRITE PAD FILES
             'showWarnings':'1',        # show or supress warning message
             'ascii':'0',               # write data in ASCII or binary
             'startTime':'0.0',         # first data time to process (0 means anything back to 1970)
             'endTime':'0.0',           # last data time to process (0 means no limit)
             'quitWhenDone':'0',        # end this program when all data is processed
             'bigEndian':'0',           # write binary data as big endian (Sun, Mac) or little endian (Intel)
             'cutoffDelay':'86400',     # maximum amount of time to keep data in the database before processing (24 hours)
             'maxFileTime':'600',       # maximum time span for a PAD file (0 means no limit)
             'additionalHeader':'\"\"'} # additional XML to put in header.
                                        #   in order to prevent confusion in the shell and command parser,
                                        #   represent XML with: ' ' replaced by '#', tab by '~', CR by '~~'
parameters = defaults.copy()
def setParameters(newParameters):
    global parameters
    parameters = newParameters.copy()
    
ancillaryData = {}
ancillaryDataFormat = {}
ancillaryXML = ''
ancillaryUpdate = 0 # next time ancillaryXML should by updated
ancillaryDatabases = ['bias', 'coord_system_db', 'data_coord_system', 'dqm', 'iss_config', 'scale']

# simple timing based benchmark routine
benTotal = 0
benCount = 0
def benchmark(startTime):
    global benCount, benTotal
    benCount = benCount + 1
    benTotal = benTotal + (time() - startTime)

# debug printer
def printDebug(s):
    """print some debug info"""
    global DEBUGPRINT
    if DEBUGPRINT:
        print s
        sleep(2)

# sample idle function
# FIXME keeping track of previous total is kludge
previousTotal = 0
def sampleIdleFunction():
    """a sample idle function"""
    global previousTotal
    if previousTotal != totalPacketsWrangled:
        print "totalPacketsWrangled %d" % totalPacketsWrangled
    previousTotal = totalPacketsWrangled

# add sample idle function
addIdle(sampleIdleFunction)

# class to keep track of what's been wrangled (processed)
class packetWrangler:
    """Class to keep track of what has been wrangled (processed)."""
    def __init__(self, showWarnings):
        """initialize this packet wrangler"""
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
    
    # DEFUNCT create the PIMS directory tree for pad files (locally)
    def buildDirTree(self, filename):
        """DEFUNCT # create the PIMS directory tree for pad files (locally)"""
        printDebug("buildDirTree input: %s" % filename)
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
            printLog(t)
            return '%s' % (y)
        return '%s' % (y)
        
    # move PAD file
    def movePadFile(self, source):
        """move PAD file"""
        dest = parameters['destination']
        if dest == '.':
            return
        if source == '':
            t =  UnixToHumanTime(time(), 1)
            t = t + ' movePadFile() bad source: %s' % source
            printLog(t)
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
                printLog(t)
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
        if parameters['ascii']:
            format = 'ascii'
        else:
            if parameters['bigEndian']:
                format = 'binary 32 bit IEEE float big endian'
            else:
                format = 'binary 32 bit IEEE float little endian'
        header = header + '\t<GData format="%s" file="%s"/>\n' % (format, dataFileName)
        # insert additionalDQM() if necessary
        aXML = ancillaryXML
        if self._headerPacket_.additionalDQM() != '':
            dqmStart = find(aXML, '<DataQualityMeasure>')
            if dqmStart == -1:
                aXML = aXML + '\t<DataQualityMeasure>%s</DataQualityMeasure>\n' % xmlEscape(self._headerPacket_.additionalDQM())
            else:
                dqmInsert = dqmStart + len('<DataQualityMeasure>')
                aXML = aXML[:dqmInsert] + xmlEscape(self._headerPacket_.additionalDQM()) + ', ' + aXML[dqmInsert:] 
        header = header + aXML
        if parameters['additionalHeader'] != '\"\"':
            header = header + parameters['additionalHeader']
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
            sensorEntry, dataEntry = checkCoordinateSystem(dataTime, sensor, dataName)
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
        global packetsWritten
        packetsWritten += 1
        #print "packetsWritten", packetsWritten
        #sleep(1)
        if self.lastPacket:
            ostart = self.lastPacket.time()
            oend = self.lastPacket.endTime()
            start = packet.time()
            printDebug('start: %0.10f end: %0.10f samples: %s packetGap: %0.10f  sampleGap: %0.10f' % (start, packet.endTime(), packet.samples(), start-ostart, start-oend))

#        print 'writePacket ' + `contiguous`
        updateAncillaryData(packet.time(), packet.name(), self)
        if contiguous == -1:
            contiguous = packet.contiguous(self.lastPacket)
        if self._forceNewFile_:
            self.begin(packet, 0)
            self._forceNewFile_ = 0
        elif not contiguous or ((parameters['maxFileTime'] > 0) and (packet.time() > (self._fileStart_ + parameters['maxFileTime']))):
            self.begin(packet, contiguous)
#        bStartTime = time() # benchmark this
        self.append(packet)
#        benchmark(bStartTime)

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
                printDebug('end() is moving %s to %s, success:%s' % (self._fileName_, newName, ok))
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
                    printLog(t)
        self._fileName_ = 'temp.' + packet.name()
        self._file_ = open(self._fileName_, 'ab')
        self._fileStart_ = packet.time()
        printDebug('begin() is starting %s' % self._fileName_)

    # append data to the file, may need to reopen it
    def append(self, packet):
        global totalPacketsWrangled
        if self._file_ == None:
            newName = 'temp.' + packet.name()
            os.system('rm -rf %s.header' % self._fileName_)
            ok = os.system('mv %s %s' % (self._fileName_, newName)) == 0
            printDebug('append() is moving %s to %s, success:%s' % (self._fileName_, newName, ok))
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

        if not parameters['ascii']:
            if parameters['bigEndian']:
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
        totalPacketsWrangled = totalPacketsWrangled + 1

# class to keep track of unexpected changes
class packetInspector(packetWrangler):
    """class to keep track of unexpected changes in header rate info"""

    # FIXME we may be able to streamline this more so by making some method
    #       routines do less/nothing; for now, just neutralize things a bit

    def __init__(self, showWarnings, padExpect=None):
        packetWrangler.__init__(self, showWarnings)
        self.padExpect = padExpect
        print self.padExpect

    def buildDirTree(self, filename):
        """do nothing for inheritance sake"""        
        pass

    def movePadFile(self, source):
        """do nothing for inheritance sake"""
        pass

    def append(self, packet):
        """inspect packet for unexpected changes (do not append to file)"""
        global totalPacketsWrangled
        if self._file_ == None:
            newName = 'temp.' + packet.name()
            os.system('rm -rf %s.header' % self._fileName_)
            ok = True #os.system('mv %s %s' % (self._fileName_, newName)) == 0
            printDebug('append() from packetInspector is NOT moving %s to %s, success:%s' % (self._fileName_, newName, ok))
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

        if not parameters['ascii']:
            if parameters['bigEndian']:
                atxyzs = atxyzs.byteswap() 
                if extra:
                    aextra = aextra.byteswap()
            if extra:
                atxyzs = concatenate((atxyzs, aextra), 1)
            #self._file_.write(atxyzs.tostring()) # NOTE THIS IS "NOT-WRITING" JUST INSPECTING
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
        totalPacketsWrangled = totalPacketsWrangled + 1
        
        # TODO this is where we track changes
        hdr = packet.header()
        expected_values = self.padExpect.values # dictionary of expected values
        for k,v in expected_values.iteritems():
            if hdr[k] != v:
                printLog("sensor (%s) expected (%s) of (%s) does not match packet value of (%s) at packet time of (%s)" % (hdr['seId'], k, v, hdr[k], unixTimeToString(hdr['time'])))
                #printLog(packet.dump())
                #{'status': 59822, 'head': False, 'endTime': 1325161782.4123819, 'name': '121f03', 'isSams2Packet': 1, 'rate': 500.0, 'gain': 10.0, 'samples': 74, 'seId': '121f03', 'adjustment': 'temperature+gain+axial-mis-alignment', 'time': 1325161782.266382, 'unit': 'g', 'eeId': '122f02'}
        sleep(0.1)

    # finished "non-writing" for a while, close and name the file if it was in use 
    def end(self):
        if self._file_ != None:
            self._file_.close()
            self._file_ = None
            if self.lastPacket:
                newName = UnixToHumanTime(self._fileStart_) + self._fileSep_ + \
                      UnixToHumanTime(self.lastPacket.endTime()) + '.' + self.lastPacket.name()
                ok = True #os.system('mv %s %s' % (self._fileName_, newName)) == 0
                printDebug('end() is moving %s to %s, success:%s' % (self._fileName_, newName, ok))
                #headFile = open(newName + '.header', 'wb')
                #headFile.write(self.buildHeader(newName))  
                #headFile.close()
                self._fileName_ = newName
                self._dataDirName_ = self.lastPacket.dataDirName()
                self._maybeMove_ = newName
            return self._fileName_

# return sensor and data coordinate system database entries, if they exist
def checkCoordinateSystem(dataTime, sensor, dataName):
    if not ancillaryData.has_key('coord_system_db'):
        t =  UnixToHumanTime(time(), 1)
        t = t + ' warning: data coordinate system "%s" requested, but "coord_system_db" was not found' % dataName
        printLog(t)
        return (0, 0) # coordinate system database doesn't exit
    csdb = ancillaryData['coord_system_db']
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
        printLog(t)
        return (0, 0) # didn't find coordinate systems entries for both sensor and data
    
# format an ancillary data entry in XML       
def addAncillaryXML(db, entry, dataTime, sensor, pw, dbMatchTime): 
    global ancillaryXML
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
        if pw.setDataCoordSystem(dataName, dataTime, sensor): 
            newLine = '\t<DataCoordinateSystem name="%s" ' % string.strip(entry[0])
            # lookup data coord system info
            sensorEntry, dataEntry = checkCoordinateSystem(dataTime, sensor, dataName)
            newLine = newLine + 'r="%s" p="%s" w="%s" x="%s" y="%s" z="%s" ' % dataEntry[2:-1]
            newLine = newLine + 'comment="%s" ' % xmlEscape(dataEntry[-1])
            newLine = newLine + 'time="%s"/>\n' % UnixToHumanTime(dataEntry[0])
        else: # coord system lookup failed, use sensor coordinates
            newLine = '\t<DataCoordinateSystem name="sensor"/>\n' 
    ancillaryXML = ancillaryXML + newLine
    
# look for valid ancillary data entries for a given sensor and time    
def  updateAncillaryXML(dataTime, sensor, pw): 
    global ancillaryXML
    ancillaryXML = ''
    adKeys = ancillaryData.keys()
    adKeys.sort() # always process databases in the same order
    for i in adKeys:
        ad = ancillaryData[i]
        format = ancillaryDataFormat[i]
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
            addAncillaryXML(i, entry, dataTime, sensor, pw, maxTime)

# rebuild all ancillary data for this sensor, if the time is right
def updateAncillaryData(dataTime, sensor, pw):
    global ancillaryUpdate, ancillaryXML
    if dataTime < ancillaryUpdate:
        return
    else:
        oldAncillaryXML = ancillaryXML
        sensor = string.lower(sensor)
        updateAncillaryXML(dataTime, sensor, pw) # update headers
        if oldAncillaryXML != ancillaryXML:
            pw._forceNewFile_ = 1
            # must end old pad file with oldAncillaryXML before using new ancillaryXML
            saveXML = ancillaryXML
            ancillaryXML = oldAncillaryXML
            pw.end()
            ancillaryXML = saveXML
        # find next scheduled ancillary change 
        maxUpdate = time()
        newUpdate = maxUpdate
        for i in ancillaryData.keys():
            ad = ancillaryData[i]
            for j in ad:
                if j[0] > dataTime and j[0] < newUpdate:
                    newUpdate = j[0]
                    break
        if newUpdate != maxUpdate:
            ancillaryUpdate = newUpdate
        else: # no need to check for any more updates
            ancillaryUpdate = time() + 10000000 # don't update at all until database changes
##        print 'next ancillary data update after %s scheduled for %s' % (dataTime, ancillaryUpdate)

# retrieve the ancillary databases
def updateAncillaryDatabases():
    global ancillaryUpdate, ancillaryData
    if parameters['ancillaryHost'] == 'None':
        ancillaryUpdate = time() + 10000000 # don't update at all
        return
    try: 
        for db in ancillaryDatabases:
            ancillaryData[db] = sqlConnect('select * from %s order by time' % db,
                 shost=parameters['ancillaryHost'], suser='pims', spasswd='pims2000', sdb='pad')
            ancillaryDataFormat[db] = sqlConnect('show columns from %s' % db,
                 shost=parameters['ancillaryHost'], suser='pims', spasswd='pims2000', sdb='pad')
        ancillaryUpdate = 0 # database may have changed, need to rebuild ancillary data
##        # dump databases for debugging
##        for i in ancillaryData.keys():
##            ad = ancillaryData[i]
##            print '%s:' % i
##            for j in ad:
##                print j
    except OperationalError, value:
        t = UnixToHumanTime(time(), 1)
        t = t + ' ancillary database error %s' % value
        printLog(t)
        sys.exit()

# dispose of processed data
def disposeProcessedData(tableName, lastTime):
    global packetsWritten
    if parameters['startTime'] > 0.0:
        minTime = parameters['startTime']
    else:
        minTime = -10000000.0 # should be negative infinity
    if parameters['delete']=='0':
        return

    # make sure the number of packets to be deleted is not less than the number written
    deleted = sqlConnect('select time from %s where time <= %.6lf and time > %.6lf' % (tableName, ceil4(lastTime), minTime),shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
    
    packetsWrittenCheck = packetsWritten
    packetsWritten = 0

    if parameters['delete']=='1': # delete processed packets here
        sqlConnect('delete from %s where time <= %.6lf and time > %.6lf' % (tableName, ceil4(lastTime), minTime),
            shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
    else: # move data to new database instead of deleting
        newTable = parameters['delete']
        # see if table exists
        tb = sqlConnect('show tables',
            shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
        for i in tb:
            if i[0] == newTable:
                break
        else: # newTable not found, must create it 
            key = '' # check if we need a primary key
            col = sqlConnect('show columns from %s' % tableName,         
                 shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
            for c in col:
                if c[0]=='time' and c[3]=='PRI':
                    key = 'PRIMARY KEY'
            sqlConnect('CREATE TABLE %s(time DOUBLE NOT NULL %s, packet BLOB NOT NULL, type INTEGER NOT NULL, header BLOB NOT NULL)' % (newTable, key),
                 shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
        sqlConnect('insert into %s select * from %s where time <= %.6lf and time > %.6lf' % (newTable,tableName,ceil4(lastTime), minTime),
            shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
        sqlConnect('delete from %s where time <= %.6lf and time > %.6lf' % (tableName, ceil4(lastTime), minTime),
            shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
        
    if packetsWrittenCheck > len(deleted): # we should throw an exception here, but generate a warning instead
        print 'WARNING: more packets were written then are being deleted'
        print 'This might mean there are extra packets in the PAD file, skewing data after this point'
        print 'Wrote %s packets to PAD file, but deleting only %s from database' % (packetsWrittenCheck, len(deleted))
        
        # try to determine where the packet not getting deleted is occuring
        around = sqlConnect('select time from %s where time <= %.6lf and time > %.6lf' % (tableName, ceil4(lastTime)+5,ceil4(lastTime)-5 ),shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
        # print out times within plus/minus 5 seconds of lastTime
        print 'The problem occurred writing and deleting packets in database time <= %.6lf' % ceil4(lastTime)
        print 'The next packet in the database to be processed is at time %.6lf' % around[0] # assumes that around will be after lastTime
  
# main packet writing loop
def mainLoop():    
    pws = {}
    if parameters['resume']: # resume where we left off by reading old state file
        try: 
            file = open('packetWriterState', 'rb')
            pws = pickle.load(file)
            file.close()
        except:
            pws = {}

    if parameters['inspect']: # do initial query to get expected values for comparison
        # do query for expected values
        if ('ALL' in parameters['tables']) or (',' in parameters['tables']):
            raise Exception('inspect routine does not handle "ALL" or comma-separated tables parameter (yet)')
        else:
            try:
                padExpect = PadExpect(sensor=parameters['tables']) # table name is sensor designator
            except:
                raise Exception('could not do query of expected values for (%s)' % parameters['tables'])

    try:
        while 1: # until killed or ctrl-C or no more data (if parameters['quitWhenDone'])
            lastPacketTotal = totalPacketsWrangled
            moreToDo = 0
            timeNow = time()
            cutoffTime = timeNow - max(parameters['cutoffDelay'], minimumDelay)
            if parameters['endTime'] > 0.0:
                cutoffTime = min(cutoffTime, parameters['endTime'])

            # build list of tables to work with
            tables = []
            
            for table in sqlConnect('show tables',
                             shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database']):
                tableName = table[0]
                columns = []
                for col in sqlConnect('show columns from %s' % tableName,
                               shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database']):
                    columns.append(col[0])
                if ('time' in columns) and ('packet' in columns):
                    tables.append(tableName)
            if parameters['tables'] != 'ALL':
                wanted = split(parameters['tables'], ',')
                newTables = []
                for w in wanted:
                    if w in tables:
                        newTables.append(w)
                    else:
                        t = UnixToHumanTime(time(), 1)
                        t = t + ' warning: table %s was not found, ignoring it' % w
                        printLog(t)
                tables = newTables
                
            for tableName in tables:
                if idleWait(0):
                    break # check for shutdown in progress

                updateAncillaryDatabases()
                
                preCutoffProgress = 0
                packetCount = 0
                if not pws.has_key(tableName):
                    if parameters['inspect']:
                        pw = packetInspector(parameters['showWarnings'],padExpect=padExpect)
                    else:
                        pw = packetWrangler(parameters['showWarnings'])
                    pws[tableName] = pw
                else:
                    pw = pws[tableName]
                start = ceil4(max(pw.lastTime(), parameters['startTime'])) # database has only 4 decimals of precision
                
                # write all packets before cutoffTime
                tpResults = sqlConnect('select time,packet from %s where time > %.6f and time < %.6f \
                            order by time limit %d' % (tableName, start, cutoffTime, maxResults),
                                       shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
                packetCount = packetCount + len(tpResults)
                while len(tpResults) != 0:
                    for result in tpResults:
                        p = guessPacket(result[1], showWarnings=1)
                        if p.type == 'unknown':
                            printLog('unknown packet type at time %.4lf' % result[0])
                            continue
                        printDebug('%7s %s %.4f %s' %(tableName, p.type, result[0], p.contiguous(pw.lastPacket)))
                        preCutoffProgress = 1                        
                        pw.writePacket(p)
                        
                    if packetCount >= maxResultsOneTable or len(tpResults) != maxResults or idleWait(0):
                        if packetCount >= maxResultsOneTable:
                            moreToDo = 1 # go work on another table for a while
                        pw.end()
                        tpResults = []
                    else:
                        start = ceil4(max(pw.lastTime(), parameters['startTime'])) # database has only 4 decimals of precision
                        tpResults = sqlConnect('select time,packet from %s where time > %.6f and time < %.6f \
                                    order by time limit %d' % (tableName, start, cutoffTime, maxResults),
                                               shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
                        packetCount = packetCount + len(tpResults)
                printDebug('finished before-cutoff packets for %s up to %.6f, moreToDo:%s' % (tableName, pw.lastTime(), moreToDo))
                    
                # write contiguous packets after cutoffTime
                if preCutoffProgress and not moreToDo:
                    packetCount = 0
                    stillContiguous = 1
                    maxTime = timeNow-minimumDelay
                    if parameters['endTime'] > 0.0:
                        maxTime = min(maxTime, parameters['endTime'])
                    if parameters['endTime'] == 0.0 or maxTime < parameters['endTime']:
                        
                        tpResults = sqlConnect('select time,packet from %s where time > %.6f and time < %.6f \
                                    order by time limit %d' % (tableName, ceil4(pw.lastTime()), maxTime, maxResults),
                                        shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
                        packetCount = packetCount + len(tpResults)
                        while stillContiguous and len(tpResults) != 0 and not idleWait(0):
                            for result in tpResults:
                                p = guessPacket(result[1])
                                if p.type == 'unknown':
                                    continue
                                printDebug('%7s %s %.4f %s' %(tableName, p.type, result[0], p.contiguous(pw.lastPacket)))
                                stillContiguous = p.contiguous(pw.lastPacket)
                                if not stillContiguous:
                                    break
                                pw.writePacket(p, stillContiguous)
                            if packetCount >= maxResultsOneTable or len(tpResults) != maxResults:
                                if packetCount >= maxResultsOneTable:
                                    moreToDo = 1 # go work on another table for a while
                                pw.end()
                                tpResults = []
                            elif stillContiguous:
                                tpResults = sqlConnect('select time,packet from %s where time > %.6f and time < %.6f \
                                            order by time limit %d' % (tableName, ceil4(pw.lastTime()), maxTime, maxResults),
                                                shost=parameters['host'], suser='pims', spasswd='pims2000', sdb=parameters['database'])
                                packetCount = packetCount + len(tpResults)
                            else:
                                tpResults = []
#                           printDebug('finished after-cutoff contiguous packets for %s up to %.6f' % (tableName, pw.lastTime()))

                pw.end()
                disposeProcessedData(tableName, pw.lastTime())

            print "totalPacketsWrangled", totalPacketsWrangled, "moreToDo", moreToDo
            if not moreToDo:
                if lastPacketTotal == totalPacketsWrangled and parameters['quitWhenDone']:
                    break # quit mainLoop() and exit the program
                if idleWait(sleepTime):
                    break # quit mainLoop() and exit the program
            else:
                if idleWait(0):
                    break # quit mainLoop() and exit the program
                

    finally:
        if benCount > 0:
            print 'benchmark average: %.6f' % (benTotal/benCount)
        # finalize any open files
        for k in pws.keys():
            dataFileName = pws[k].end()
            if  pws[k]._maybeMove_ != '':
                pws[k].movePadFile(pws[k]._maybeMove_)
        # keep track of where we left off
        file = open('packetWriterState', 'wb')
        pickle.dump(pws, file)
        file.close()

# check parameters
def parametersOK():        
    b = parameters['inspect']
    if b != '0' and b != '1':
        printLog(' inspect must be 0 or 1')
        return 0
    else:
        parameters['inspect'] = atoi(parameters['inspect'])

    b = parameters['resume']
    if b != '0' and b != '1':
        printLog(' resume must be 0 or 1')
        return 0
    else:
        parameters['resume'] = atoi(parameters['resume'])

    b = parameters['showWarnings']
    if b != '0' and b != '1':
        printLog(' showWarnings must be 0 or 1')
        return 0
    else:
        parameters['showWarnings'] = atoi(parameters['showWarnings'])
        
    b = parameters['ascii']
    if b != '0' and b != '1':
        printLog(' ascii must be 0 or 1')
        return 0
    else:
        parameters['ascii'] = atoi(parameters['ascii'])
        
    b = parameters['quitWhenDone']
    if b != '0' and b != '1':
        printLog(' quitWhenDone must be 0 or 1')
        return 0
    else:
        parameters['quitWhenDone'] = atoi(parameters['quitWhenDone'])
        
    b = parameters['bigEndian']
    if b != '0' and b != '1':
        printLog(' bigEndian must be 0 or 1')
        return 0
    else:
        parameters['bigEndian'] = atoi(parameters['bigEndian'])
        
    b = parameters['delete']
    if b != '0' and b != '1': # delete must be specifying a database name for moving data
        # make sure there is only one table specified
        if parameters['tables']=='ALL' or len(split(parameters['delete'], ',')) != 1:
            printLog(' you must specify only 1 table with "tables=" if you')
            printLog(' set "delete=" to a table name for moving data instead of deleting')
            return 0

    b = parameters['additionalHeader']
    if b != '\"\"':
        b = string.replace(b, '#', ' ')      # replace hash marks with spaces
        b = string.replace(b, '~~', chr(10)) # replace double tilde with carriage returns
        b = string.replace(b, '~', chr(9))   # replace single tilde with tab
        parameters['additionalHeader'] = b

    parameters['startTime'] = atof(parameters['startTime'])
    parameters['endTime'] = atof(parameters['endTime'])
    parameters['cutoffDelay'] = atof(parameters['cutoffDelay'])
    parameters['maxFileTime'] = atof(parameters['maxFileTime'])

    b = parameters['destination']
    if b != '.':
        printLog(UnixToHumanTime(time(), 1) + ' testing scp connection...')
        dest = split(b, ':')
        if len(dest) != 2:
            printLog(' destination must be in ssh format: hostname:/directory/to/store/to')
            return 0
        host,directory = dest
        r = getoutput(" touch scptest;scp -p scptest %s" % (b))
        if len(r) != 0:
            printLog(' scp test failed')
            printLog(' host: %s, directory: %s, error: %s' % (host,directory,r))
            sys.exit()
        printLog(' scp OK')

    if 0 == parameters['resume']:
        # remove any stale resume files
        getoutput('rm -rf packetWriterState temp.*')
    
    return 1

# print usage
def printUsage():
    print version
    print 'usage: packetWrangler.py [options]'
    print '       options (and default values) are:'
    for i in defaults.keys():
        print '            %s=%s' % (i, defaults[i])

if __name__ == '__main__':
    for p in sys.argv[1:]:  # parse command line
        pair = split(p, '=', 1)
        if (2 != len(pair)):
            print 'bad parameter: %s' % p
            break
        if not parameters.has_key(pair[0]):
            print 'bad parameter: %s' % pair[0]
            break
        else:
            parameters[pair[0]] = pair[1]
    else:
        if parametersOK():
            if parameters['inspect']:
                printLog('packetWrangler starting with inspection mode')
            else:
                printLog('packetWrangler starting')
            mainLoop() 
            sys.exit()
    printUsage()
