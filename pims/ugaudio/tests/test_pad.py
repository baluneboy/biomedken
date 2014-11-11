#!/usr/bin/env python

import os
import unittest
import numpy as np
import tempfile
from pims.ugaudio.create import write_chirp_pad
from pims.ugaudio.pad import PadFile

class SignalTestCase(unittest.TestCase):
    """
    Test suite for ugaudio.signal.
    """

    def setUp(self):
        """
        Get set up for tests.
        """        
        # create good, dummy pad file
        self.good_file_object = tempfile.NamedTemporaryFile(delete=False)
        self.good_filename = self.good_file_object.name
        write_chirp_pad(self.good_filename)
        self.good_file_object.close()

        # create good, somewhat legitimate pad header file
        self.dummyrate = 123.456
        self.good_header_filename = self.good_filename + '.header'
        with open(self.good_header_filename, 'w') as hf:
            hf.write("<SampleRate>%f</SampleRate>\n" % self.dummyrate)
        
        # create bad, dummy pad file
        self.bad_file_object = tempfile.NamedTemporaryFile(delete=False)
        self.bad_filename = self.bad_file_object.name
        self.bad_file_object.write("bad")
        self.bad_file_object.close()
        
    def test_is_pad(self):
        """
        Tests the is_pad method.
        """
        # test simple, good (dummy) pad file
        good_pad_file = PadFile(self.good_filename)
        self.assertTrue(good_pad_file.ispad)
        
        # test non-pad file
        not_pad_file = PadFile(self.bad_filename)
        self.assertFalse(not_pad_file.ispad)        

    def test_get_headerfile(self):
        """
        Tests the get_headerfile method.
        """    
        # test simple, good (dummy) pad file
        good_pad_file = PadFile(self.good_filename)
        self.assertTrue(good_pad_file.ispad)
        
        # and its header file
        header_file = good_pad_file.headerfile
        self.assertTrue( os.path.exists(header_file) )
        
    def test_get_samplerate(self):
        """
        Tests the get_samplerate method.
        """    
        # test simple, good (dummy) pad file
        good_pad_file = PadFile(self.good_filename)
        self.assertTrue(good_pad_file.ispad)
        
        # and its header file
        header_file = good_pad_file.headerfile
        self.assertTrue( os.path.exists(header_file) )
        
        # now its dummy sample rate
        self.assertEqual( good_pad_file.samplerate, self.dummyrate )
        
    @unittest.skip("not implemented yet")
    def test_convert(self):
        """
        Tests the convert method.
        """    
        raise Exception('not implemented yet')

def suite():
    return unittest.makeSuite(SignalTestCase, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite', verbosity=2)