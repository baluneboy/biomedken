#!/usr/bin/env python
version = '$Id$'

# FIXME major kludges when I added "every 5 minutes" intrms (new page and more links)

import os
import sys
import datetime
import shutil
import glob
import re
from HTMLgen import *
from collections import OrderedDict
from pims.realtime.buffer_move import main as cleanBuffer
from recipes_fileutils import fileAgeDays
# http://pims.grc.nasa.gov/plots/sams/121f05/intrms_10sec_5hz.html
# Linux command for future reference:
# find /misc/yoda/www/plots/sams -mindepth 2 -maxdepth 2 -type f -mmin -60 -name "*.jpg" -exec ls -l --full-time {} \; | grep -v "/interesting/"

# regardless, always do RMS to 121f05intrms.html (every 5 minutes)
# if minutes in [00 30], then also do non-RMS to index.html

##################################################################################################################################
# GLOB PATTERN                                           REGEXP TO PARSE SENSOR                       SUFFIX FOR HTML  STEPMINUTES
_GLOB_PATS = [
('/misc/yoda/www/plots/sams/121f0*/121f0*.jpg',         '/misc/yoda/www/plots/sams/(.*)/.*',         '',               30 ),
('/misc/yoda/www/plots/sams/es0*/es0*.jpg',             '/misc/yoda/www/plots/sams/(.*)/.*',         '',               30 ),
('/misc/yoda/www/plots/sams/laible/121f0*/121f0*.jpg',  '/misc/yoda/www/plots/sams/laible/(.*)/.*',  'ten',            30 ),
('/misc/yoda/www/plots/oss/osstmf/ML_OSSTMF.jpg',       '/misc/yoda/www/plots/oss/(.*)/.*',          '',               30 ),
('/misc/yoda/www/plots/sams/hirap/hirap.jpg',           '/misc/yoda/www/plots/sams/(.*)/.*',         '',               30 ),
('/misc/yoda/www/plots/sams/121f0*/intrms_*.png',       '/misc/yoda/www/plots/sams/(.*)/.*',         'rms',             5 ),
]

def getRecentlySnappedSensors(stepMinutes=30, minutesOld=60):
    """ return OrderedDict of sensors with recently-snapped real-time images, some
    examples:
    sensors['121f02']    = '/misc/yoda/www/plots/sams/121f02/121f02.jpg'
    sensors['hirap']     = '/misc/yoda/www/plots/sams/hirap/hirap.jpg'
    sensors['ossbtmf']   = '/misc/yoda/www/plots/oss/osstmf/ML_OSSTMF.jpg'
    # Below are special cases for Mike Laible (JSC/Boeing) or Hayato Ohkuma (JAXA)
    sensors['121f03ten'] = '/misc/yoda/www/plots/sams/laible/121f03/121f03.jpg'
    sensors['121f04one'] = '/misc/yoda/www/plots/sams/laible/121f04/121f04_grid.jpg'
    sensors['121f05ten'] = '/misc/yoda/www/plots/sams/laible/121f05/121f05.jpg'
    sensors['121f08one'] = '/misc/yoda/www/plots/sams/laible/121f08/121f08_grid.jpg'
    """
    sensors = OrderedDict()
    ###                     GLOB PATTERN                                           REGEXP TO PARSE SENSOR                   SUFFIX FOR HTML
    ##snapGlobPats = [    ('/misc/yoda/www/plots/sams/121f0*/121f0*.jpg',         '/misc/yoda/www/plots/sams/(.*)/.*',         '' ),
    ##                    ('/misc/yoda/www/plots/sams/es0*/es0*.jpg',             '/misc/yoda/www/plots/sams/(.*)/.*',         '' ),
    ##                    ('/misc/yoda/www/plots/sams/laible/121f0*/121f0*.jpg',  '/misc/yoda/www/plots/sams/laible/(.*)/.*',  'ten' ),
    ##                    ('/misc/yoda/www/plots/oss/osstmf/ML_OSSTMF.jpg',       '/misc/yoda/www/plots/oss/(.*)/.*',          '' ),
    ##                    ('/misc/yoda/www/plots/sams/hirap/hirap.jpg',           '/misc/yoda/www/plots/sams/(.*)/.*',         '' ),
    ##                    ('/misc/yoda/www/plots/sams/121f0*/intrms_*.png',       '/misc/yoda/www/plots/sams/(.*)/.*',         'rms' ),
    ##                ]
    ##for wildPath, pat, suffix in snapGlobPats:
    for wildPath, pat, suffix, step in _GLOB_PATS:
        results = glob.glob(wildPath)
        regexp = re.compile(pat)
        #print wildPath, len(results)
        for fname in results:
            match = regexp.match(fname)
            if match:
                sensor = match.group(1)
            else:
                sensor = 'unknown'
            sensor += suffix
            fileAgeMinutes = fileAgeDays(fname) * 1440
            if fileAgeMinutes < minutesOld and stepMinutes == step:
                sensors[sensor] = fname
    return sensors

def midnight(d):
    return datetime.datetime.combine(d,datetime.time(0,0,0))

def nextHalfHour(d):
    dtm = midnight(d) - datetime.timedelta(minutes=30)
    while 1:
        dtm += datetime.timedelta(minutes=30)
        yield (dtm)

def nextFiveMinutes(d):
    dtm = midnight(d) - datetime.timedelta(minutes=5)
    while 1:
        dtm += datetime.timedelta(minutes=5)
        yield (dtm)

def timeStampedSensorName(dtm, sensor):
    return dtm.strftime('%Y_%m_%d_%H_%M_') + sensor + '.jpg'

# class for every 30 minutes
class SensorContainer(Container):
    """class for every 30 minutes"""
    
    def __init__(self, *args, **kw):
        Container.__init__(self, *args, **kw)
        self.day = kw['day']
        self.sensor = kw['sensor']
        #self.append(Heading(3, self.sensor))
        self.append(Bold(Text(self.sensor)))
        self.append(BR(1))
        self.appendTimeSubdivisions()
        self.append(BR(1))

    def appendTimeSubdivisions(self):
        n = nextHalfHour(self.day)
        for k in range(3):
            half = [n.next() for i in range(0,16)]
            for h in half:
                linkPath = os.path.join('/misc/yoda/www/plots/user/buffer/' + timeStampedSensorName(h, self.sensor))
                if os.path.exists(linkPath):
                    self.append(Href('http://pims.grc.nasa.gov/plots/user/buffer/' + timeStampedSensorName(h, self.sensor), h.strftime('%H:%M')))
                else:
                    self.append(Text(h.strftime('%H:%M')))
            self.append(BR(1))

# class for every 5 minutes
class SensorContainerFive(SensorContainer):
    """class for every 5 minutes"""

    def appendTimeSubdivisions(self):
        n = nextFiveMinutes(self.day)
        for k in range(12):
            twelfth = [n.next() for i in range(0,24)]
            for h in twelfth:
                linkPath = os.path.join('/misc/yoda/www/plots/user/buffer/' + timeStampedSensorName(h, self.sensor))
                if os.path.exists(linkPath):
                    self.append(Href('http://pims.grc.nasa.gov/plots/user/buffer/' + timeStampedSensorName(h, self.sensor), h.strftime('%H:%M')))
                else:
                    self.append(Text(h.strftime('%H:%M')))
            self.append(BR(1))

class DayContainerFive(Container):

    def __init__(self, *args, **kw):
        Container.__init__(self, *args, **kw)
        self.day = kw['day']
        self.sensorSuperset = kw['sensorSuperset']
        self.append(HR())
        self.append(Heading(3, self.day.strftime('GMT %d-%b-%Y')))
        self.appendSensors()
    
    def appendSensors(self):
        for s in self.sensorSuperset:
            self.append( SensorContainerFive(day=self.day, sensor=s) )   
            
class DayContainer(DayContainerFive):
    
    def __init__(self, *args, **kw):
        DayContainerFive.__init__(self, *args, **kw)
        
    def appendSensors(self):
        for s in self.sensorSuperset:
            self.append( SensorContainer(day=self.day, sensor=s) )

def createDoc(title):
    " Create HTML document with heading. "
    heading = title + ' (updated at GMT %s)' % datetime.datetime.now().strftime("%d-%b-%Y/%H:%M:%S")
    doc = SimpleDocument(title=title)
    doc.append( Heading(3, heading) )
    return doc

def disclaimer():
    #
    d = Text('Plots linked below may show time gaps due to LOS, however, those will get filled in ')
    d.append( Href('http://pims.grc.nasa.gov/roadmap','roadmap PDFs.') )
    d.append(BR(1))
    d = Text('Near real-time plots Interval RMS plots are buffered more frequently at ')
    d.append( Href('http://pims.grc.nasa.gov/plots/user/buffer/intrms.html','this link.') )
    d.append(BR(1))    
    d.append('For help, contact')
    d.append(Href('mailto:pimsops@grc.nasa.gov','pimsops@grc.nasa.gov'))
    return d

def otherLinksTable(clean_msg):
    table = Table(
    tabletitle='Other PIMS Products',
    border=2, width=240, cell_align="center",
    heading=[ "Try The Links in This Table" ])
    table.body = []       # Empty list.
    table.body.append( [
        Href('http://pims.grc.nasa.gov/roadmap', 'roadmaps') ] )
    table.body.append( [
        Href('http://pims.grc.nasa.gov/plots/user/buffer/recent','recent (' +
        clean_msg + ')') ] )
    return table

def updateIndexHTML(clean_msg, sensorSuperset):

    # Create HTML doc with title and heading
    doc = createDoc('PIMS ~2-Day Buffer for Real-Time Screenshots')

    # Append disclaimer
    doc.append(disclaimer())

    # Append ~2-day buffer links
    today = datetime.date.today()
    dc1 = DayContainer(day=today, sensorSuperset=sensorSuperset)
    doc.append(dc1)
  
    yesterday = datetime.date.today() - datetime.timedelta(days=1)  
    dc2 = DayContainer(day=yesterday, sensorSuperset=sensorSuperset)
    doc.append(dc2)

    doc.append(HR())

    ## Do "old file" clean-up
    #clean_msg = cleanBuffer()
    
    # Append other links table
    doc.append(otherLinksTable(clean_msg))

    # Write to output HTML file    
    doc.write("/misc/yoda/www/plots/user/buffer/index.html")

def updateRMSHTML(clean_msg, sensorSuperset):

    # Create HTML doc with title and heading
    doc = createDoc('PIMS ~2-Days of Near Real-Time Interval RMS Screenshots')

    # Append ~2-day buffer links
    today = datetime.date.today()
    dc1 = DayContainerFive(day=today, sensorSuperset=sensorSuperset)
    doc.append(dc1)
  
    yesterday = datetime.date.today() - datetime.timedelta(days=1)  
    dc2 = DayContainerFive(day=yesterday, sensorSuperset=sensorSuperset)
    doc.append(dc2)

    doc.append(HR())

    # Write to output HTML file
    doc.write("/misc/yoda/www/plots/user/buffer/intrms.html")

def roundTime(dt=None, roundTo=60):
   """Round a datetime object to any time lapse in seconds
   dt : datetime.datetime object, default now.
   roundTo : Closest number of seconds to round to, default 1 minute.
   Author: Thierry Husson 2012 - Use it as you want but don't blame me.
   """
   if dt == None : dt = datetime.datetime.now()
   seconds = (dt - dt.min).seconds
   # // is a floor division, not a comment on following line:
   rounding = (seconds+roundTo/2) // roundTo * roundTo
   return dt + datetime.timedelta(0,rounding-seconds,-dt.microsecond)

def copySnaps(sensorDict, roundTo):
    """ copy screenshots produced by real-time to buffer directory with
    timestamp and sensor in name """
    for theSensor, snapFile in sensorDict.iteritems():
        dtm = roundTime(roundTo=roundTo)
        shutil.copy2(snapFile, os.path.join('/misc/yoda/www/plots/user/buffer/' +
            timeStampedSensorName(dtm, theSensor)))
        #print snapFile, "copied"
    
    # Do "old file" clean-up
    clean_msg = cleanBuffer()
    return clean_msg

def main(stepMinutes):
    sensorDict = getRecentlySnappedSensors(stepMinutes=stepMinutes, minutesOld=60)
    sensorSuperset = sensorDict.keys()
    if stepMinutes == 30:
        clean_msg = copySnaps(sensorDict, roundTo=1800) # 30 minutes
        updateIndexHTML(clean_msg, sensorSuperset)
    elif stepMinutes == 5:
        clean_msg = copySnaps(sensorDict, roundTo=300)  # 5 minutes
        updateRMSHTML(clean_msg, sensorSuperset)
    else:
        return -1
    return 0

if __name__ == '__main__':
    stepMinutes = int( sys.argv[1] )
    sys.exit(main(stepMinutes))
