#!/usr/bin/env python

"""
PAD file management...
a very loose interpretation of what a PAD file is.
"""

# Author: Ken Hrovat
# Disclaimer: this code can be much improved

import os
import re
import aifc
import struct
import numpy as np
from pims.ugaudio.load import array_fromfile
from pims.ugaudio.signal import normalize
import matplotlib.pyplot as plt

# class for loosely managing PAD files
class PadFile(object):
    """class for loosely managing PAD files"""
    
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
            #return '%s named %s (native rate = %.3f sa/sec)' % (self.__class__.__name__, bname, self.samplerate)
            return '%s, native rate = %.3f sa/sec' % (bname, self.samplerate)
        elif self.exists:
            return '%s (non-%s)' % (bname, self.__class__.__name__)
        else:
            return '%s (non-file)' % bname
    
    # loose check for pad file
    def is_pad(self):
        """loose check for pad file"""
        # NOTE: this assumes PAD file that has 4 columns (like SAMS)
        
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
    
    # get header filename if it exists
    def get_headerfile(self):
        """get header filename if it exists"""
        
        hdrfile = self.filename + '.header'
        if os.path.exists(hdrfile):
            return hdrfile
        else:
            return None
    
    # reckon sample rate from time step in data file
    def _reckon_rate(self):
        """reckon sample rate from time step in data file"""
        
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
    
    # try to parse sample rate from header file; otherwise reckon it from t 
    def get_samplerate(self):
        """try to parse sample rate from header file; otherwise reckon it from t"""
        
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
    
    # TODO: include other parts of processing chain (taper, filter, pitch shifting, frequency shifting)
    # TODO: with processing chain, you should grow an encoded message to echo and use as outfile suffix:
    #       like RATFS would be nstfs would be native rate, s-axis, tapered, filtered, shifted
    #       or   RATFS would be NxTfS would be Not native rate, x-axis, Not tapered, filtered, Not shifted
    # convert designated axis to aiff and maybe plot too
    def convert(self, rate=None, axis='s', plot=False):
        """convert designated axis to aiff and maybe plot too"""
    
        # check loosely if pad file
        if not self.ispad:
            return
    
        # get sample rate
        if not rate:
            samplerate = self.samplerate
        else:
            samplerate = rate
            
        #print self
                
        # read data from file
        B = array_fromfile(self.filename)
    
        # demean each column
        M = B.mean(axis=0)
        C = B - M[np.newaxis, :]
       
        # determine axis
        for ax in axis.lower():
            if ax == 'x':   data = C[:, -3] # x-axis is 3rd last column
            elif ax == 'y': data = C[:, -2] # y-axis is 2nd last column
            elif ax == 'z': data = C[:, -1] # z-axis is the last column
            elif ax == 's': data = C[:, 1::].sum(axis=1) # sum(x+y+z)
            else:
                raise Exception( 'unhandled axis "%s"' % ax )
        
            # maybe plot demeaned accel data
            if plot:
                png_file = self.filename + ax + '.png'
                plt.plot(data)
                plt.savefig(png_file)
                
            # normalize to range -32768:32767 (actually, use -32000:32000)
            data = normalize(data) * 32000.0
        
            # data conditioning
            data = data.astype(np.int16) # not sure why we need this...maybe aifc assumptions
            data = data.byteswap().newbyteorder() # need this on mac osx and linux (windows?)
        
            # convert data to string for aifc to work write
            strdata = data.tostring()
            aiff_file = self.filename + ax + '.aiff'
            g = aifc.open(aiff_file, 'w')
            sampwidth = 2 # we get this value based on data type (np.int16)
            #         nchans, sampwidth, framerate, nframes, comptype, compname
            g.setparams((1, sampwidth, samplerate, len(data), 'NONE', 'not compressed'))
            g.writeframes(strdata)
            g.close()
