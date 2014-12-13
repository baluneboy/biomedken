#!/usr/bin/env python

"""geometry

W = width of clock window
D = width of display
H = number of hours to traverse width of display
dt = time step in minutes
k = n*dt = time value after n steps
num = numerator = k * (D - W)
den = denominator = 60 * H

So, the x-value (in px) for right edge of clock window as function of time is:
x(k) = W + ( num / den )

"""

import math
import warnings
from Tkinter import Tk
try:
    import winsound
except ImportError:
    import os
    def playsound(frequency, duration):
        os.system('echo "\a"')
else:
    def playsound(frequency, duration):
        winsound.Beep(frequency, duration)

# need this to override warnings default "only once/first"
warnings.simplefilter('always', UserWarning)

class TkGeometryKeeper(object):

    root = Tk()
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()

    def __init__(self, w, h, x, y, sound_on=False):
        self.sound_on = sound_on
        self.set_w( w )
        self.set_h( h )
        self.set_x( x )
        self.set_y( y )

    def __str__(self):
        return '%dx%d+%d+%d' % (self.w, self.h, self.x, self.y)

    # make sure we stay in bounds
    def _get_value_in_range(self, value, min_val, max_val):
        """make sure we stay in bounds"""
        if value < min_val:
            msg = 'value cannot be less than lower limit of %d' % min_val
            val = min_val
        elif value > max_val:
            msg = 'value cannot be more than upper limit of %d' % max_val
            val = max_val
        else:
            msg = None
            val = value
        if msg and self.sound_on: playsound(440, 1)
        return val, msg

    # set width without going out of bounds
    def set_w(self, w):
        """set width without going out of bounds"""
        val, msg = self._get_value_in_range(w, 0, self.screen_width)
        self.w = val
        if msg: warnings.warn('width ' + msg)

    # set height without going out of bounds
    def set_h(self, h):
        """set height without going out of bounds"""
        val, msg = self._get_value_in_range(h, 0, self.screen_height)
        self.h = val
        if msg: warnings.warn('height ' + msg)
        
    # set x-coordinate without going out of bounds
    def set_x(self, x):
        """set x-coordinate without going out of bounds"""
        val, msg = self._get_value_in_range(x, 0, self.screen_width)
        self.x = val
        if msg: warnings.warn('x-coordinate ' + msg)

    # set y-coordinate without going out of bounds
    def set_y(self, y):
        """set y-coordinate without going out of bounds"""
        val, msg = self._get_value_in_range(y, 0, self.screen_height)
        self.y = val
        if msg: warnings.warn('y-coordinate ' + msg)

# simple circular generator to yield x coordinate value
def circular(xstart, xstop, xstep):
    """simple circular generator to yield x coordinate value"""
    while True:
        for x in range(xstart, xstop, xstep):
            yield x

class TkGeometryIterator(TkGeometryKeeper):
    
    def __init__(self, cross_hours, dt_minutes, w, h, x, y, sound_on=False):
        super(TkGeometryIterator, self).__init__(w, h, x, y, sound_on=sound_on)
        xstart = 0
        xstop = self.screen_width - w
        xstep = int( math.ceil( (xstop - xstart) * dt_minutes / (60 * cross_hours) ) )
        self.cycle = circular(xstart, xstop, xstep)
    
    def xnext(self):
        return self.cycle.next()
