#!/usr/bin/python

import unittest
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
        # set specific seed value such that random numbers are reproducible
        np.random.seed(815)
        header = {'network': 'BW', 'station': 'BGLD',
                  'starttime': UTCDateTime(2007, 12, 31, 23, 59, 59, 915000),
                  'npts': 412, 'sampling_rate': 200.0,
                  'channel': 'EHE'}
        trace1 = Trace(data=np.random.randint(0, 1000, 412).astype('float64'),
                       header=deepcopy(header))
        header['starttime'] = UTCDateTime(2008, 1, 1, 0, 0, 4, 35000)
        header['npts'] = 824
        trace2 = Trace(data=np.random.randint(0, 1000, 824).astype('float64'),
                       header=deepcopy(header))
        header['starttime'] = UTCDateTime(2008, 1, 1, 0, 0, 10, 215000)
        trace3 = Trace(data=np.random.randint(0, 1000, 824).astype('float64'),
                       header=deepcopy(header))
        header['starttime'] = UTCDateTime(2008, 1, 1, 0, 0, 18, 455000)
        header['npts'] = 50668
        trace4 = Trace(
            data=np.random.randint(0, 1000, 50668).astype('float64'),
           header=deepcopy(header))
        self.mseed_stream = PadStream(traces=[trace1, trace2, trace3, trace4])
        header = {'network': '', 'station': 'RNON ', 'location': '',
                  'starttime': UTCDateTime(2004, 6, 9, 20, 5, 59, 849998),
                  'sampling_rate': 200.0, 'npts': 12000,
                  'channel': '  Z'}
        trace = Trace(
            data=np.random.randint(0, 1000, 12000).astype('float64'),
            header=header)
        self.gse2_stream = PadStream(traces=[trace])

    def test_countAndLen(self):
        """
        Tests the count and __len__ methods of the PadStream object.
        """
        # empty stream without traces
        stream = PadStream()
        self.assertEqual(len(stream), 0)
        self.assertEqual(stream.count(), 0)
        # stream with traces
        stream = read()
        self.assertEqual(len(stream), 3)
        self.assertEqual(stream.count(), 3)
            
def suite():
    return unittest.makeSuite(PadProcessChainTestCase, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite')
