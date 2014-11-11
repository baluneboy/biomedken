#!/usr/bin/env python

import os
import unittest
import numpy as np
import tempfile
from pims.ugaudio.create import write_chirp_pad, write_rogue_pad_file
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
        self.pad_file_object = tempfile.NamedTemporaryFile(delete=False)
        self.pad_filename = self.pad_file_object.name
        write_chirp_pad(self.pad_filename)
        self.pad_file_object.close()

        # create good, somewhat legitimate pad header file
        self.dummyrate = 123.456
        self.pad_header_filename = self.pad_filename + '.header'
        with open(self.pad_header_filename, 'w') as hf:
            hf.write("one\n<SampleRate>%f</SampleRate>\n3" % self.dummyrate)
        
        # create rogue pad file (without header file)
        values = [
            [0.0, -1.2,  9.9, -1.4],
            [1.0,  2.2, -9.9,  2.4],
            [2.0, -3.2,  9.9, -3.4],
            [3.0,  4.2, -9.9,  4.4],
            [4.0, -5.2,  9.9, 55.4],
            [5.0,  6.2, -9.9,  6.4],
            [6.0, -7.2,  9.9, -7.4],
            [7.0,  8.2, -9.9,  8.4],
            [8.0, -9.2,  9.9, -9.4],
            ]    
        self.rogue_file_object = tempfile.NamedTemporaryFile(delete=False)
        self.rogue_filename = self.rogue_file_object.name
        write_rogue_pad_file(values, self.rogue_filename)
        self.rogue_file_object.close()
        
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
        good_pad_file = PadFile(self.pad_filename)
        self.assertTrue(good_pad_file.ispad)
        
        # test non-pad file
        not_pad_file = PadFile(self.bad_filename)
        self.assertFalse(not_pad_file.ispad)        

    def test_get_headerfile(self):
        """
        Tests the get_headerfile method.
        """    
        # test simple, good (dummy) pad file
        good_pad_file = PadFile(self.pad_filename)
        self.assertTrue(good_pad_file.ispad)
        
        # test header file exists
        header_file = good_pad_file.headerfile
        self.assertTrue( os.path.exists(header_file) )
        
    def test_get_samplerate_with_header_file(self):
        """
        Tests the get_samplerate method via header file.
        """    
        # test simple, good (dummy) pad file
        good_pad_file = PadFile(self.pad_filename)
        self.assertTrue(good_pad_file.ispad)
        
        # test header file exists
        header_file = good_pad_file.headerfile
        self.assertTrue( os.path.exists(header_file) )
        
        # test its dummy sample rate
        self.assertEqual( good_pad_file.samplerate, self.dummyrate )

    def test_get_samplerate_without_header_file(self):
        """
        Tests the get_samplerate method using _reckon_rate.
        """    
        # test simple, good (dummy) pad file [rogue without header]
        rogue_pad_file = PadFile(self.rogue_filename)
        self.assertTrue(rogue_pad_file.ispad)
        
        # make sure header file does not exist (that is, it's None)
        self.assertIsNone( rogue_pad_file.headerfile )
        
        # test its dummy sample rate
        self.assertEqual( rogue_pad_file.samplerate, 1.0 )

    @unittest.skip("not implemented yet")       
    def test_convert_with_defaults(self):
        """
        Tests the convert method with defaults.
        That is, at native rate, s-axis, no plot, and no taper.
        """
        # 
        raise Exception('not implemented yet')

def suite():
    return unittest.makeSuite(SignalTestCase, 'test')

if __name__ == '__main__':
    unittest.main(defaultTest='suite', verbosity=2)