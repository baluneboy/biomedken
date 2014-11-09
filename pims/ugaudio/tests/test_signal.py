# -*- coding: utf-8 -*-

import unittest
import numpy as np
from pims.ugaudio.signal import normalize, my_taper, timearray

# return signal of length n with alternating integers: +v, -v, +v, -v,...
def alternate_integers(v, n):
    """return signal of length n with alternating integers: +v, -v, +v, -v,..."""
    x = np.empty((n,), int)
    x[::2]  = +v
    x[1::2] = -v
    return x

class SignalTestCase(unittest.TestCase):
    """
    Test suite for ugaudio.signal.
    """

    def setUp(self):
        """
        Get set up for tests.
        """        
        ## set specific seed value such that random numbers are reproducible
        #np.random.seed(123)
        self.not_normalized = alternate_integers(9, 5)
        self.not_tapered = alternate_integers(100, 401)

    def test_normalize(self):
        """
        Tests the normalize function.
        """
        y = normalize( self.not_normalized )
        # compare extremes
        self.assertEqual(-1, np.min(y))
        self.assertEqual(+1, np.max(y))
        self.assertEqual(-9, np.min(self.not_normalized))
        self.assertEqual(+9, np.max(self.not_normalized))

    def test_my_taper(self):
        """
        Tests the my_taper function.
        """
        fs = 100
        t = 1
        y = my_taper(self.not_tapered, fs, t)
        # compare endpts
        self.assertEqual(y[0], 0)
        self.assertEqual(y[-1], 0)
        self.assertEqual(self.not_tapered[0],  100)
        self.assertEqual(self.not_tapered[-1], 100)        
        # compare midpt area
        self.assertEqual(np.abs(y[199]), 100)
        self.assertEqual(self.not_tapered[199], -100)
        # compute taper region's index range from t seconds
        idx_midtaper = (fs/2)/t
        self.assertNotEqual(np.abs(y[idx_midtaper]), 100)
        self.assertEqual(np.abs(self.not_tapered[idx_midtaper]), 100)        
        self.assertNotEqual(np.abs(y[-idx_midtaper]), 100)
        self.assertEqual(np.abs(self.not_tapered[-idx_midtaper]), 100)  

    def test_sort(self):
        """
        Tests the sort method of the Stream object.
        """
        # Create new Stream
        stream = Stream()
        # Create a list of header dictionaries. The sampling rate serves as a
        # unique identifier for each Trace.
        headers = [
            {'starttime': UTCDateTime(1990, 1, 1), 'network': 'AAA',
             'station': 'ZZZ', 'channel': 'XXX', 'sampling_rate': 100.0},
            {'starttime': UTCDateTime(1990, 1, 1), 'network': 'AAA',
             'station': 'YYY', 'channel': 'CCC', 'sampling_rate': 200.0},
            {'starttime': UTCDateTime(2000, 1, 1), 'network': 'AAA',
             'station': 'EEE', 'channel': 'GGG', 'sampling_rate': 300.0},
            {'starttime': UTCDateTime(1989, 1, 1), 'network': 'AAA',
             'station': 'XXX', 'channel': 'GGG', 'sampling_rate': 400.0},
            {'starttime': UTCDateTime(2010, 1, 1), 'network': 'AAA',
             'station': 'XXX', 'channel': 'FFF', 'sampling_rate': 500.0}]
        # Create a Trace object of it and append it to the Stream object.
        for _i in headers:
            new_trace = Trace(header=_i)
            stream.append(new_trace)
        # Use normal sorting.
        stream.sort()
        self.assertEqual([i.stats.sampling_rate for i in stream.traces],
                         [300.0, 500.0, 400.0, 200.0, 100.0])
        # Sort after sampling_rate.
        stream.sort(keys=['sampling_rate'])
        self.assertEqual([i.stats.sampling_rate for i in stream.traces],
                         [100.0, 200.0, 300.0, 400.0, 500.0])
        # Sort after channel and sampling rate.
        stream.sort(keys=['channel', 'sampling_rate'])
        self.assertEqual([i.stats.sampling_rate for i in stream.traces],
                         [200.0, 500.0, 300.0, 400.0, 100.0])
        # Sort after npts and sampling_rate and endtime.
        stream.sort(keys=['npts', 'sampling_rate', 'endtime'])
        self.assertEqual([i.stats.sampling_rate for i in stream.traces],
                         [100.0, 200.0, 300.0, 400.0, 500.0])
        # The same with reverted sorting
        # Use normal sorting.
        stream.sort(reverse=True)
        self.assertEqual([i.stats.sampling_rate for i in stream.traces],
                         [100.0, 200.0, 400.0, 500.0, 300.0])
        # Sort after sampling_rate.
        stream.sort(keys=['sampling_rate'], reverse=True)
        self.assertEqual([i.stats.sampling_rate for i in stream.traces],
                         [500.0, 400.0, 300.0, 200.0, 100.0])
        # Sort after channel and sampling rate.
        stream.sort(keys=['channel', 'sampling_rate'], reverse=True)
        self.assertEqual([i.stats.sampling_rate for i in stream.traces],
                         [100.0, 400.0, 300.0, 500.0, 200.0])
        # Sort after npts and sampling_rate and endtime.
        stream.sort(keys=['npts', 'sampling_rate', 'endtime'], reverse=True)
        self.assertEqual([i.stats.sampling_rate for i in stream.traces],
                         [500.0, 400.0, 300.0, 200.0, 100.0])
        # Sorting without a list or a wrong item string should fail.
        self.assertRaises(TypeError, stream.sort, keys=1)
        self.assertRaises(TypeError, stream.sort, keys='sampling_rate')
        self.assertRaises(TypeError, stream.sort, keys=['npts', 'starttime',
                                                        'wrong_value'])

    def test_sortingTwice(self):
        """
        Sorting twice should not change order.
        """
        stream = Stream()
        headers = [
            {'starttime': UTCDateTime(1990, 1, 1),
             'endtime': UTCDateTime(1990, 1, 2), 'network': 'AAA',
             'station': 'ZZZ', 'channel': 'XXX', 'npts': 10000,
             'sampling_rate': 100.0},
            {'starttime': UTCDateTime(1990, 1, 1),
             'endtime': UTCDateTime(1990, 1, 3), 'network': 'AAA',
             'station': 'YYY', 'channel': 'CCC', 'npts': 10000,
             'sampling_rate': 200.0},
            {'starttime': UTCDateTime(2000, 1, 1),
             'endtime': UTCDateTime(2001, 1, 2), 'network': 'AAA',
             'station': 'EEE', 'channel': 'GGG', 'npts': 1000,
             'sampling_rate': 300.0},
            {'starttime': UTCDateTime(1989, 1, 1),
             'endtime': UTCDateTime(2010, 1, 2), 'network': 'AAA',
             'station': 'XXX', 'channel': 'GGG', 'npts': 10000,
             'sampling_rate': 400.0},
            {'starttime': UTCDateTime(2010, 1, 1),
             'endtime': UTCDateTime(2011, 1, 2), 'network': 'AAA',
             'station': 'XXX', 'channel': 'FFF', 'npts': 1000,
             'sampling_rate': 500.0}]
        # Create a Trace object of it and append it to the Stream object.
        for _i in headers:
            new_trace = Trace(header=_i)
            stream.append(new_trace)
        stream.sort()
        a = [i.stats.sampling_rate for i in stream.traces]
        stream.sort()
        b = [i.stats.sampling_rate for i in stream.traces]
        # should be equal
        self.assertEqual(a, b)

    def test_mergeGaps(self):
        """
        Test the merge method of the Stream object.
        """
        stream = self.mseed_stream
        
        # KH
        log.debug('\n')
        for tr in stream:
            log.debug( '%s' % tr )
        
        start = UTCDateTime("2007-12-31T23:59:59.915000")
        end =   UTCDateTime("2008-01-01T00:04:31.790000")
        self.assertEquals(len(stream), 4)
        self.assertEquals(len(stream[0]), 412)
        self.assertEquals(len(stream[1]), 824)
        self.assertEquals(len(stream[2]), 824)
        self.assertEquals(len(stream[3]), 50668)
        self.assertEquals(stream[0].stats.starttime, start)
        self.assertEquals(stream[3].stats.endtime, end)
        for i in xrange(4):
            self.assertEquals(stream[i].stats.sampling_rate, 200)
            self.assertEquals(stream[i].getId(), 'BW.BGLD..EHE')
        stream.verify()
        # merge it
        stream.merge()
        stream.verify()
        self.assertEquals(len(stream), 1)
        self.assertEquals(len(stream[0]), stream[0].data.size)
        self.assertEquals(stream[0].stats.starttime, start)
        self.assertEquals(stream[0].stats.endtime, end)
        self.assertEquals(stream[0].stats.sampling_rate, 200)
        self.assertEquals(stream[0].getId(), 'BW.BGLD..EHE')

        # KH
        log.debug('\n')
        for tr in stream:
            log.debug( '%s' % tr )

    def test_split(self):
        """
        Testing splitting of streams containing masked arrays.
        """
        # 1 - create a Stream with gaps
        tr1 = Trace(data=np.ones(4, dtype=np.int32) * 1)
        tr2 = Trace(data=np.ones(3, dtype=np.int32) * 5)
        tr2.stats.starttime = tr1.stats.starttime + 9
        st = Stream([tr1, tr2])
        st.merge()
        
        # KH
        log.debug('\n\ntest_split')
        for tr in st:
            log.debug( '%s' % tr )        
        
        self.assertTrue(isinstance(st[0].data, np.ma.masked_array))
        # now we split again
        st2 = st.split()
        
        # KH
        log.debug('\n')
        for tr in st2:
            log.debug( '%s' % tr ) 
        
        self.assertEqual(len(st2), 2)
        self.assertTrue(isinstance(st2[0].data, np.ndarray))
        self.assertTrue(isinstance(st2[1].data, np.ndarray))
        self.assertEqual(st2[0].data.tolist(), [1, 1, 1, 1])
        self.assertEqual(st2[1].data.tolist(), [5, 5, 5])
        # 2 - use default example
        st = self.mseed_stream
        st.merge()
        self.assertTrue(isinstance(st[0].data, np.ma.masked_array))
        # now we split again
        st2 = st.split()
        self.assertEquals(len(st2), 4)
        self.assertEquals(len(st2[0]), 412)
        self.assertEquals(len(st2[1]), 824)
        self.assertEquals(len(st2[2]), 824)
        self.assertEquals(len(st2[3]), 50668)
        self.assertEquals(st2[0].stats.starttime,
                          UTCDateTime("2007-12-31T23:59:59.915000"))
        self.assertEquals(st2[3].stats.endtime,
                          UTCDateTime("2008-01-01T00:04:31.790000"))
        for i in xrange(4):
            self.assertEquals(st2[i].stats.sampling_rate, 200)
            self.assertEquals(st2[i].getId(), 'BW.BGLD..EHE')

    def test_plot(self):
        """
        Tests plot method if matplotlib is installed
        """
        try:
            import matplotlib  # @UnusedImport
        except ImportError:
            return
        self.mseed_stream.plot(show=False)

    def test_spectrogram(self):
        """
        Tests spectrogram method if matplotlib is installed
        """
        try:
            import matplotlib  # @UnusedImport
        except ImportError:
            return
        self.mseed_stream.spectrogram(show=False)

def suite():
    return unittest.makeSuite(SignalTestCase, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite', verbosity=3)