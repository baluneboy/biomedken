#!/usr/bin/env python

import copy
import numpy as np
import warnings
from scipy.signal import hann

# return signal of length numpts with alternating integers: +value, -value, +value,...
class AlternateIntegers(object):
    """
    return signal of length numpts with alternating integers: +value, -value, +value,...
    used as simple signal for test purposes
    """
    
    def __init__(self, value=9, numpts=5):
        self.value = value
        self.numpts = numpts
        self.signal = self.alternate_integers()
        
        idxmid = numpts // 2
        if numpts % 2 == 0:
            self.idx_midpts = [idxmid-1, idxmid]
        else:
            self.idx_midpts = [idxmid]

    def alternate_integers(self):
        x = np.empty((self.numpts,), int)
        x[::2]  = +self.value
        x[1::2] = -self.value
        return x

# normalize amplitude of the signal
def normalize(a):
    """normalize amplitude of the signal"""
    sf = max(abs(a))
    if sf == 0:
        return a
    return a / sf

# return numpts; at most, this is one-third of signal duration
def clip_at_third(sig, fs, t):
    """return numpts; at most, this is one-third of signal duration"""
    # number of pts to taper (maybe)
    Ndesired = int(fs * t)
    
    # ensure that taper is, at most, a third of signal duration
    third = len(sig) // 3
    if Ndesired > third:
        Nactual = third
        warnings.warn( 'Desired taper %d pts > ~one-third (%d pts) of signal. Just tapering a third of signal duration.' % (Ndesired, Nactual), RuntimeWarning )
    else:
        Nactual = Ndesired
    #print Ndesired, Nactual, len(sig), third
    return Nactual

# taper signal for first & last t seconds
def my_taper(a, fs, t):
    """taper signal for first & last t seconds"""
    # number of pts to taper (at most, one-third of signal)
    N = clip_at_third(a, fs, t)
    
    # use portion of hann (w) to do the tapering
    w = hann(2*N+1)
    
    # work on signal copy, leave input alone
    b = a.copy()
    b[0:N] *= w[0:N]
    b[-N:] *= w[-N:]
    return b

# return time array (helpful to plot versus time)
def timearray(y, fs):
    """return time array (helpful to plot vs. time)"""
    T = len(y) / float(fs) # total time of the signal
    return np.linspace(0, T, len(y), endpoint=False)

# multiply the sound's speed by some factor
def speedx(sound_array, factor):
    """multiply the sound's speed by some factor"""
    indices = np.round( np.arange(0, len(sound_array), factor) )
    indices = indices[indices < len(sound_array)].astype(int)
    return sound_array[ indices.astype(int) ]

# stretch the sound by a factor, f
def stretch(sound_array, f, window_size, h):
    """stretch the sound by a factor, f"""
    
    phase  = np.zeros(window_size)
    hanning_window = np.hanning(window_size)
    result = np.zeros( len(sound_array) /f + window_size)

    for i in np.arange(0, len(sound_array)-(window_size+h), h*f):

        # two potentially overlapping subarrays
        a1 = sound_array[i: i + window_size]
        a2 = sound_array[i + h: i + window_size + h]

        # resynchronize the second array on the first
        s1 =  np.fft.fft(hanning_window * a1)
        s2 =  np.fft.fft(hanning_window * a2)
        phase = (phase + np.angle(s2/s1)) % 2*np.pi
        a2_rephased = np.fft.ifft(np.abs(s2)*np.exp(1j*phase))

        # add to result
        i2 = int(i/f)
        result[i2 : i2 + window_size] += hanning_window*a2_rephased

    result = ((2**(16-4)) * result/result.max()) # normalize (16bit)

    return result.astype('int16')

# change the pitch of a sound by n semitones
def pitchshift(snd_array, n, window_size=2**13, h=2**11):
    """change the pitch of a sound by n semitones"""
    factor = 2**(1.0 * n / 12.0)
    stretched = stretch(snd_array, 1.0/factor, window_size, h)
    return speedx(stretched[window_size:], factor)