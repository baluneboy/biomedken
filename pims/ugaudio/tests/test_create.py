#!/usr/bin/env python

import unittest
import tempfile
import numpy as np
from pims.ugaudio.load import array_fromfile
from pims.ugaudio.create import AlternateIntegers, padwrite

# Test suite for ugaudio.create.
class CreateTestCase(unittest.TestCase):
    """
    Test suite for ugaudio.create.
    """

    def setUp(self):
        """
        Get set up for tests.
        """        
        # create simple test signals
        self.alt_ints = AlternateIntegers(value=5, numpts=10)
        self.sample_rate = 10

    def test_padwrite(self):
        """
        Test the padwrite function.
        """
        fs = self.sample_rate
        x = self.alt_ints.signal
        y = x + 2
        z = x - y
        
        # write simple pad file (and get time vector)
        self.pad_file_object = tempfile.NamedTemporaryFile(delete=False)
        self.pad_filename = self.pad_file_object.name
        t = padwrite(x, y, z, fs, self.pad_filename, return_time=True)
        self.pad_file_object.close()
        
        # FIXME this is flimsy here because we rely on ouwr own array_fromfile
        a = array_fromfile(self.pad_filename)
        tout, xout, yout, zout = a[:,0], a[:,1], a[:,2], a[:,3]

        # verify each column (t,x,y,z) from file closely matches expected value
        small_delta = 1e-6 # true for our simple integer case with fs = 1 sa/sec
        self.assertLess( np.max( np.abs(tout - t) ), small_delta)
        self.assertLess( np.max( np.abs(xout - x) ), small_delta)
        self.assertLess( np.max( np.abs(yout - y) ), small_delta)
        self.assertLess( np.max( np.abs(zout - z) ), small_delta)

    @unittest.skip("not implemented yet")
    def test_something(self):
        """
        Test something here.
        """
        pass
    
def suite():
    return unittest.makeSuite(CreateTestCase, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite', verbosity=2)