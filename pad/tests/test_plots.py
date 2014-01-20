#!/usr/bin/python

import unittest
import os
import pickle
import numpy as np
from copy import deepcopy
from obspy import UTCDateTime, Trace, read
from pims.pad.padstream import PadStream
from pims.pad.processchain import PadProcessChain
from pims.signal.ramp import ramp
from scipy import signal

def filter_setup():
    t = np.linspace(0, 10.0, 5001)
    # for xhigh, use a = sqrt(2) so rms = a / sqrt(2) = 1
    xhigh = np.sqrt(2) * np.sin(2 * np.pi * 25 * t) # 25 Hz
    xlow = np.sin(2 * np.pi * 2 * t)                # 2 Hz
    x = xlow + xhigh
    return t, x, xlow, xhigh

def build_sines():
    t, x, xlow, xhigh = filter_setup()
    x = xlow + xhigh
    y = xlow
    z = xhigh
    header = {'network': 'KH', 'station': 'SINE',
              'starttime': UTCDateTime(2011, 12, 10, 6, 30, 00),
              'npts': 5001, 'sampling_rate': 500.0,
              'channel': 'x'}        
    tracex = Trace(data=x, header=deepcopy(header))
    header['channel'] = 'y'
    tracey = Trace(data=y, header=deepcopy(header))
    header['channel'] = 'z'
    tracez = Trace(data=z, header=deepcopy(header))    
    return tracex, tracey, tracez
    
def build_ramps(npts):
    slopes = [11.1, 0, -9.9] # x, y, and z
    intercepts = [-5.0, -3.0, 1.0]
    t = np.linspace(0, 20*np.pi, npts)
    x = ramp(t, slope=slopes[0], yint=intercepts[0], noise=True, noise_amplitude=5)
    y = ramp(t, slope=slopes[1], yint=intercepts[1], noise=True, noise_amplitude=5)
    z = ramp(t, slope=slopes[2], yint=intercepts[2], noise=True, noise_amplitude=5)
    header = {'network': 'KH', 'station': 'RAMP',
              'starttime': UTCDateTime(2011, 12, 10, 6, 30, 00),
              'npts': 5001, 'sampling_rate': 500.0,
              'channel': 'x'}        
    tracex = Trace(data=x, header=deepcopy(header))
    header['channel'] = 'y'
    tracey = Trace(data=y, header=deepcopy(header))
    header['channel'] = 'z'
    tracez = Trace(data=z, header=deepcopy(header))    
    return tracex, tracey, tracez

class PlotsTestCase(unittest.TestCase):
    """
    Test suite for PadProcessChain.
    """

    def setUp(self):
        # we saved a pickled substream (p) file in pims/pad/tests/substream.p
        pth = os.path.dirname(__file__).replace('/gui/', '/pad/')
        pickled_substream = os.path.join( pth, 'substream.p')
        self.saved_substream = pickle.load( open(pickled_substream, 'rb') )
        # create normally-distributed random stream w/ mu, sigma known
        self.mu, self.sigma = 8.76, 0.54 # mean and standard deviation
        header = {'network': 'KH', 'station': 'BANG',
                  'starttime': UTCDateTime(2001, 5, 3, 23, 59, 59, 999000),
                  'npts': 5001, 'sampling_rate': 500.0,
                  'channel': 'x'}        
        tracex = Trace(data=np.random.normal(self.mu, self.sigma, 5001).astype('float64'),
                       header=deepcopy(header))
        header['channel'] = 'y'
        tracey = Trace(data=np.random.normal(self.mu, self.sigma, 5001).astype('float64'),
                       header=deepcopy(header))
        header['channel'] = 'z'
        tracez = Trace(data=np.random.normal(self.mu, self.sigma, 5001).astype('float64'),
                       header=deepcopy(header))
        self.valid_substream = PadStream(traces=[tracex, tracey, tracez])
        # create linear ramp random stream, per-axis (x,y,z)
        tracex, tracey, tracez = build_ramps(5001)
        self.ramps_substream = PadStream(traces=[tracex, tracey, tracez])
        # create two-sinusoid waveform for x, xlow for y, and xhigh for z
        tracex, tracey, tracez = build_sines()
        self.sines_substream = PadStream(traces=[tracex, tracey, tracez])
        
    def test_is_valid_substream(self):
        """Valid substream!?"""
        self.assertEqual( True, self.saved_substream.is_valid_substream() )
        self.assertEqual( True, self.valid_substream.is_valid_substream() )
        tracex = self.valid_substream[0]
        tracez = self.valid_substream[2]
        tracey = self.valid_substream[1]
        wrong_order_stream = PadStream(traces=[tracex, tracez, tracey])
        self.assertNotEqual( True, wrong_order_stream )
        
def suite():
    return unittest.makeSuite(PlotsTestCase, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite')
