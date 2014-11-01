#!/usr/bin/env python

"""
PAD file (mis)management...
a very loose interpretation of what a PAD file is.
"""

# Author: Ken Hrovat
# Disclaimer: this code can be much improved

import os
import re
import struct

# class for managing PAD files
class PadFile(object):
    """class for managing PAD files"""
    
    def __init__(self, filename):
        self.filename = filename
        self.headerfile = None
        self.samplerate = None
        self.ispad = False
        self.exists = False
        if self.is_pad():
            self.ispad = True
            self.headerfile = self.get_headerfile()
            self.samplerate = self.get_samplerate()

    def __str__(self):
        bname = os.path.basename(self.filename)
        if self.ispad:
            return '%s object named %s (%.3f sa/sec)' % (self.__class__.__name__, bname, self.samplerate)
        elif self.exists:
            return 'non-%s object named %s (file exists)' % (self.__class__.__name__, bname)
        else:
            return 'non-%s object named %s (file does not exist)' % (self.__class__.__name__, self.filename)            
    
    def is_pad(self):
        """this assumes PAD file that has 4 columns (like SAMS)"""
        if not os.path.exists(self.filename):
            return False
        self.exists = True
        fsize = os.path.getsize(self.filename)
        if fsize == 0:
            return False
        # FIXME hard-coded 4 as "column" size (MAMS will not work)
        if fsize % 4 != 0:
            return False
        return True
    
    def get_headerfile(self):
        hdrfile = self.filename + '.header'
        if os.path.exists(hdrfile):
            return hdrfile
        else:
            return None
    
    def _reckon_rate(self):
        # FIXME we again assume 4 columns here
        with open(self.filename, 'rb') as f:
            # PAD files use relative time in seconds with t1 = 0 and next time starting
            # at byte 16, so seek to that position
            f.seek(4*4)
        
            # now we want just one 4-byte float (float32)
            b = f.read(4)
        
        # decode time step (delta t) as little-endian float32
        delta_t = struct.unpack('<f', b)[0]
        
        # return sample rate
        return round(1.0 / delta_t, 3)
    
    def get_samplerate(self):
        # try to parse sample rate from header file; otherwise reckon it from t
        if self.headerfile:
            with open(self.headerfile, 'r') as f:
                contents = f.read().replace('\n', '')
                m = re.match('.*\<SampleRate\>(.*)\</SampleRate\>.*', contents)
                if m:
                    return float( m.group(1) )
                else:
                    return None
        else:
            return self._reckon_rate()
