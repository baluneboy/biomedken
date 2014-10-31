#!/usr/bin/env python

"""
Manage PAD file.
"""

# Author: Ken Hrovat
# Disclaimer: this code can be much improved

import os

# class for managing PAD files
class PadFile(object):
    """class for managing PAD files"""
    
    def __init__(self, filename):
        self.filename = filename
        self.headerfile = self.get_header_file()
        self.samplerate = self.get_sample_rate()

    def __str__(self):
        return '%s named %s' % (self.__class__.__name__, self.filename)
    
    def exists(self):
        pass
    
    def get_header_file(self):
        hdrfile = self.filename + '.header'
        if os.path.exists(hdrfile):
            return hdrfile
        else:
            return None
    
    def get_sample_rate(self):
        # try to parse sample rate from header; otherwise reckon it from t
        pass


pf = PadFile('hoboy')
print pf