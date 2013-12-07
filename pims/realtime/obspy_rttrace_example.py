#!/usr/bin/env python

###############################################################################
# For SeedLink RtTrace example, see:
# /usr/lib/python2.7/dist-packages/obspy/seedlink/tests/example_SL_RTTrace.py
###############################################################################

# TODO see ~/dev/programs/python/realtime/examples$ komodo strip_chart_example.py

import sys
import traceback
import logging

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

from obspy.core.utcdatetime import UTCDateTime
from obspy.realtime.rttrace import RtTrace
from obspy.seedlink.seedlinkexception import SeedLinkException
from obspy.seedlink.slclient import SLClient
from obspy.seedlink.slpacket import SLPacket

# log
logging.basicConfig(filename='/tmp/pims_realtime.log', level=logging.DEBUG,
                    format='%(asctime)s,%(name)s,%(levelname)s: %(message)s')
log = logging.getLogger('pims.realtime')
log.info('Logging started.')

class MySLClient(SLClient):
    """
    A custom SeedLink client.
    """
    def __init__(self, rt_trace=RtTrace(), *args, **kwargs):
        """
        Creates a new instance of SLClient accepting a realtime trace handler.
        """
        self.rt_trace = rt_trace
        super(self.__class__, self).__init__(*args, **kwargs)

    def packetHandler(self, count, slpack):
        """
        Processes each packet received from the SeedLinkConnection.

        This method should be overridden when sub-classing SLClient.

        :type count: int
        :param count:  Packet counter.
        :type slpack: :class:`~obspy.seedlink.SLPacket`
        :param slpack: packet to process.
        :return: Boolean true if connection to SeedLink server should be \
            closed and session terminated, false otherwise.
        """
        # check if not a complete packet
        if slpack is None or (slpack == SLPacket.SLNOPACKET) or \
                (slpack == SLPacket.SLERROR):
            return False

        # get basic packet info
        seqnum = slpack.getSequenceNumber()
        type = slpack.getType()

        # process INFO packets here
        if (type == SLPacket.TYPE_SLINF):
            return False
        if (type == SLPacket.TYPE_SLINFT):
            print "-" * 40
            print "Complete INFO:\n" + self.slconn.getInfoString()
            if self.infolevel is not None:
                return True
            else:
                return False

        # can send an in-line INFO request here
        if (count % 100 == 0):
            infostr = "ID"
            self.slconn.requestInfo(infostr)

        # if here, must be a data blockette
        print "-" * 40
        print self.__class__.__name__ + ": packet seqnum:",
        print str(seqnum) + ": blockette type: " + str(type)

        # process packet data
        trace = slpack.getTrace()
        if trace is not None:
            print self.__class__.__name__ + ": blockette contains a trace: ",
            print trace.id, trace.stats['starttime'],
            print " dt:" + str(1.0 / trace.stats['sampling_rate']),
            print " npts:" + str(trace.stats['npts']),
            print " sampletype:" + str(trace.stats['sampletype']),
            print " dataquality:" + str(trace.stats['dataquality'])
            # Custom: append packet data to RtTrace
            #g_o_check = True    # raises Error on gap or overlap
            g_o_check = False   # clears RTTrace memory on gap or overlap
            self.rt_trace.append(trace, gap_overlap_check=g_o_check,
                                 verbose=True)
            length = self.rt_trace.stats.npts / self.rt_trace.stats.sampling_rate
            print self.__class__.__name__ + ":",
            print "append to RTTrace: npts:", str(self.rt_trace.stats.npts),
            print "length:" + str(length) + "s"
            print "rt_trace: ", self.rt_trace
            print "last several samples: ", self.rt_trace[-9:]

            # post processing to do something interesting
            peak = np.amax(np.abs(self.rt_trace.data))
            print self.__class__.__name__ + ": abs peak = " + str(peak)
        else:
            print self.__class__.__name__ + ": blockette contains no trace"

        return False

def main():
    # initialize realtime trace
    rttrace = RtTrace(max_length=30) # seconds
    rttrace.registerRtProcess(np.abs) # also see rttrace.registerRtProcess('integrate')

    # width in num samples
    boxcar_width = 10 * int(rttrace.stats.sampling_rate + 0.5)
    rttrace.registerRtProcess('boxcar', width=boxcar_width)

    print "The SeedLink client collects data packets & appends them to RTTrace object."

    # create SeedLink client
    slClient = None
    try:
        slClient = MySLClient(rt_trace=rttrace)

        #slClient.slconn.setSLAddress("geofon.gfz-potsdam.de:18000")
        #slClient.multiselect = ("GE_STU:BHZ")

        #slClient.slconn.setSLAddress("discovery.rm.ingv.it:39962")
        #slClient.multiselect = ("IV_MGAB:BHZ")

        slClient.slconn.setSLAddress("rtserve.iris.washington.edu:18000")
        slClient.multiselect = ("AT_TTA:BHZ")
        
        # set a time window from 90 sec in the past to 30 sec in the future
        dt = UTCDateTime()
        slClient.begin_time = (dt - 90.0).formatSeedLink()
        slClient.end_time = (dt + 30.0).formatSeedLink()
        print "SeedLink date-time range:", slClient.begin_time, " -> ",
        print slClient.end_time
        slClient.verbose = 3
        slClient.initialize()
        slClient.run()
    except SeedLinkException as sle:
        log.critical(sle)
        traceback.print_exc()
        raise sle
    except Exception as e:
        sys.stderr.write("Error:" + str(e))
        traceback.print_exc()
        raise e

class CheapDemoSpecgram(object):
    """cheap animated specgram demo using RtTrace!"""    
    
    def __init__(self, fig):
        self.fig = fig
    
    def initialize(self):
        """initialize animation"""
        ##global fig, ax, t, fs, Nfft, No, tzero_text
        self.fs, self.Nfft, self.No = 2000, 1024, 512
        self.t = self.getTimeInSeconds(0.0, 20.0)     
        self.ax = self.fig.add_subplot(111) #, autoscale_on=False, xlim=(-2, 2), ylim=(-2, 2))
        self.tzero_text = self.ax.text(0.05, 0.9, '', transform=self.ax.transAxes)
        self.im = self.specgram()
        return self.im, self.tzero_text
    
    def animate(self, i):
        """perform animation step, return tuple of things that change"""
        ##global fig, ax, t, fs, Nfft, No, tzero_text
        self.t += 100.0/self.fs
        self.tzero_text.set_text('t[0] = %.3fs' % self.t[0])
        self.im = self.specgram()
        return self.im, self.tzero_text

    def getTimeInSeconds(self, tmin, tmax):
        """generate time array (in seconds) based on sample rate (fs) and min/max"""
        return np.arange(tmin, tmax, 1.0/self.fs)
    
    def getSignal(self):
        """this has to be made '3d' for xyz accel signal, but for now..."""
        s1 = np.sin(2 * np.pi * 100 * self.t)
        s2 = 2*np.sin(2 * np.pi * 500 * self.t)
        # create a transient "chirp" (zero s2 signal before/after chirp)
        mask = np.where(np.logical_and(self.t>10, self.t<12), 1.0, 0.0)
        s2 = s2 * mask
        # add some noise into the mix
        nse = 0.01*np.random.randn(len(self.t))/1.0
        s = s1 + s2 + nse
        return s # the signal
    
    def specgram(self):
        """spectrogram"""
        y = self.getSignal()
        self.Pxx, self.fbins, self.tbins, self.im = plt.specgram(y, Fs=self.fs, NFFT=self.Nfft, noverlap=self.No, cmap=plt.get_cmap('jet') )
        return self.im
    
def cheap_demo_specgram():
    fig = plt.figure()
    cds = CheapDemoSpecgram(fig)
    ani = animation.FuncAnimation(fig, cds.animate, init_func=cds.initialize, interval=500, blit=True) # interval in msec
    plt.show()    

if __name__ == '__main__':
    #main()
    cheap_demo_specgram()
