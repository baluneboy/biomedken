#!/usr/bin/python

import unittest
import os
import pickle
import numpy as np
from copy import deepcopy
from obspy import UTCDateTime, Trace, read
from pims.pad.padstream import PadStream
from pims.pad.processchain import PadProcessChain

class PadProcessChainTestCase(unittest.TestCase):
    """
    Test suite for PadProcessChain.
    """

    def setUp(self):
        # path relative to this module (file) is where we save pickled substream (p) file
        pickled_substream = os.path.join( os.path.dirname(__file__), 'substream.p')
        self.saved_substream = pickle.load( open(pickled_substream, 'rb') )
        # concoct one of our own
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

    #def test_scale(self):
    #    """Test data scaling via scale_factor attribute."""
    #    ppc = PadProcessChain()
    #    tr = 
    #    ppc.scale(tr)

def suite():
    return unittest.makeSuite(PadProcessChainTestCase, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite')
