#!/usr/bin/env python

import numpy as np
from scipy.signal import hann

# normalize amplitude of the signal
def normalize(a):
    """normalize amplitude of the signal"""
    sf = max(abs(a))
    if sf == 0:
        return a
    return a / sf

# taper signal at both ends
def my_taper(a, fs, t):
    """taper signal for first/last t seconds"""
    N = int(fs * t)
    if (N + 1) > len(a)//3:
        print 'Oops, you are trying to taper too much.  We will only taper about one-third of signal duration.'
        N = len(a)//3
        #print N, len(a), len(a)//3
    w = hann(2*N+1)
    a[0:N+1] *= w[0:N+1]
    a[-N-1:] *= w[-N-1:]
    return a

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