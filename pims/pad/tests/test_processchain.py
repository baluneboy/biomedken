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
    xlow = np.sin(2 * np.pi * 3 * t)
    xhigh = np.sin(2 * np.pi * 25 * t)
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

class PadProcessChainTestCase(unittest.TestCase):
    """
    Test suite for PadProcessChain.
    """

    def setUp(self):
        # path relative to this module (file) is where we save pickled substream (p) file
        pickled_substream = os.path.join( os.path.dirname(__file__), 'substream.p')
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

    def test_get_units(self):
        """Test _get_units method."""
        ppc = PadProcessChain()
        self.assertEqual( 'ug', ppc._get_units() )
        ppc = PadProcessChain(scale_factor=1e3)
        self.assertEqual( 'mg', ppc._get_units() )
        # try to initialize with bad scale_factor
        kwargs = {'scale_factor':999.9}
        self.assertRaises(ValueError, PadProcessChain, **kwargs )

    def test_scale(self):
        """Test data scaling via scale_factor attribute."""
        ppc = PadProcessChain()
        tr = Trace(data=np.ones(9)*17)
        self.assertEqual( 17.0, np.max([tr]) )
        ppc.scale(tr)
        self.assertEqual( 17000000.0, np.max([tr]) )
        ppc = PadProcessChain(scale_factor=1e3)
        tr = Trace(data=np.ones(9)*17)
        self.assertEqual( 17.0, np.max([tr]) )
        ppc.scale(tr)
        self.assertEqual( 17000.0, np.max([tr]) )

    def test_detrend(self):
        """Test data detrend via detrend method on substream."""
        # simple demean (default)
        ppc = PadProcessChain()
        ppc.detrend(self.saved_substream)
        self.assertAlmostEqual( 0.0, np.mean([self.saved_substream[0]]) )
        self.assertAlmostEqual( 0.0, np.mean([self.saved_substream[1]]) )
        self.assertAlmostEqual( 0.0, np.mean([self.saved_substream[2]]) )
        # now remove linear trend
        ppc = PadProcessChain(detrend_type='linear')
        ppc.detrend(self.ramps_substream)
        self.assertAlmostEqual( 0.0, np.mean([self.ramps_substream[0]]) )
        self.assertAlmostEqual( 0.0, np.mean([self.ramps_substream[1]]) )
        self.assertAlmostEqual( 0.0, np.mean([self.ramps_substream[2]]) )        

    def test_filter(self):
        """Test data filtering via filter method on substream."""
        # default 5 Hz LPF
        ppc = PadProcessChain()
        #self.sines_substream.plot()
        ppc.filter(self.sines_substream)
        #self.sines_substream.plot()        
        # After 5 Hz lowpass filtering, x and y traces should be almost equal
        diff = np.abs( self.sines_substream.select(channel='x')[0].data - \
                       self.sines_substream.select(channel='y')[0].data).max()
        self.assertAlmostEqual( 0.0, diff, 0)
        #self.assertAlmostEqual()

def suite():
    return unittest.makeSuite(PadProcessChainTestCase, 'test')

def view_waveforms():
    tracex, tracey, tracez = build_ramps(5001)
    ramps_substream = PadStream(traces=[tracex, tracey, tracez])
    ramps_substream.plot()
    
#view_waveforms(); raise SystemExit

def view_filter_setup():
    import matplotlib.pyplot as plt    
    t, x, xlow, xhigh = filter_setup()
    plt.plot(t, x)
    plt.show()
    ## Now create a lowpass Butterworth filter with a cutoff of 0.125x Nyquist (125 Hz)
    ## and apply it to x with filtfilt. The result should be approximately xlow, with no phase shift.
    #b, a = signal.butter(9, 0.02)
    #y = signal.filtfilt(b, a, x)
    #print np.abs(y - xlow).max()
    #plt.plot(t, y)
    #plt.show()
    
#view_filter_setup(); raise SystemExit

if __name__ == '__main__':
    unittest.main(defaultTest='suite')
