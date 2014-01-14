#!/usr/bin/python

import unittest
import os
import pickle
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
        self.pad_process_chain = PadProcessChain()

    def test_is_valid_substream(self):
        """Valid substream!?"""
        self.assertEqual( True, self.saved_substream.is_valid_substream() )

    def test_get_units(self):
        """Test _get_units method."""
        ppc = PadProcessChain()
        self.assertEqual( 'ug', ppc._get_units() )
        ppc = PadProcessChain(scale_factor=1e3)
        self.assertEqual( 'mg', ppc._get_units() )
        # try to initialize with bad scale_factor
        kwargs = {'scale_factor':999.9}
        self.assertRaises(ValueError, PadProcessChain, **kwargs )

def suite():
    return unittest.makeSuite(PadProcessChainTestCase, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite')
