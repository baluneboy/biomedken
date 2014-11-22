#!/usr/bin/env python

import unittest
import tempfile
import numpy as np
from pims.ugaudio.load import padread, aiffread
from pims.ugaudio.create import AlternateIntegers, padwrite

# Test suite for ugaudio.create.
class LoadTestCase(unittest.TestCase):
    """
    Test suite for ugaudio.load.
    """

    def setUp(self):
        """
        Get set up for tests.
        """        
        # create simple test signals
        pass
        
    @unittest.skip("not implemented yet")
    def test_padread(self):
        """
        Test padread function with actual PAD file sample.
        """
        pass
        
    @unittest.skip("not implemented yet")
    def test_aiffread(self):
        """
        Test aiffread function.
        """
        pass
        
    @unittest.skip("not implemented yet")
    def test_something(self):
        """
        Test something here.
        """
        pass
    
def suite():
    return unittest.makeSuite(LoadTestCase, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite', verbosity=2)