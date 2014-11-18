#!/usr/bin/env python

import copy
import warnings
import numpy as np
from scipy.signal import hann

# Return amplitude normalized version of input signal.
def normalize(a):
    """Return amplitude normalized version of input signal."""
    sf = max(abs(a))
    if sf == 0:
        return a
    return a / sf

# Return numpts (desired = fs * t); at most though, a third of signal duration.
def clip_at_third(sig, fs, t):
    """Return numpts (desired = fs * t); at most though, a third of signal duration."""
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

# Return tapered copy of input signal; taper first & last t seconds.
def my_taper(a, fs, t):
    """Return tapered copy of input signal; taper first & last t seconds."""
    # number of pts to taper (at most, one-third of signal)
    N = clip_at_third(a, fs, t)
    
    # use portion of hann (w) to do the tapering
    w = hann(2*N+1)
    
    # work on signal copy, leave input alone
    b = a.copy()
    b[0:N] *= w[0:N]
    b[-N:] *= w[-N:]
    return b

# Return time array derived from sample rate and length of input signal.
def timearray(y, fs):
    """Return time array derived from sample rate and length of input signal."""
    T = len(y) / float(fs) # total time of the signal
    return np.linspace(0, T, len(y), endpoint=False)

# Return signal with "speed" scaled by some factor.
def speed_scale(s, factor):
    """Return signal with "speed" scaled by some factor."""
    indices = np.round( np.arange(0, len(s), factor) )
    indices = indices[indices < len(s)].astype(int)
    return s[ indices.astype(int) ]

# Return signal "stretched" by factor of f.
def stretch(s, f, window_size, h):
    """Return signal "stretched" by factor of f."""
    phase  = np.zeros(window_size)
    hanning_window = np.hanning(window_size)
    result = np.zeros( len(s) /f + window_size)

    for i in np.arange(0, len(s)-(window_size+h), h*f):
        # two potentially overlapping subarrays
        a1 = s[i: i + window_size]
        a2 = s[i + h: i + window_size + h]

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

# Return signal with pitch shifted by n semitones.
def pitch_shift(s, n, window_size=2**13, h=2**11):
    """Return signal with pitch shifted by n semitones."""
    factor = 2**(1.0 * n / 12.0)
    stretched = stretch(s, 1.0/factor, window_size, h)
    return speed_scale(stretched[window_size:], factor)