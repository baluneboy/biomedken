#!/usr/bin/python

import os
import scipy.io

# return tuple (b, a, fsNew) from matlab mat-file
def load_filter_coeffs(mat_file):
    """return tuple (b, a, fsNew) from matlab mat-file"""
    matdict = scipy.io.loadmat(mat_file)
    a = matdict['aDen']
    b = matdict['bNum']
    fsNew = matdict['fsNew']
    # need ravel method to "unnest" numpy ndarray
    return a.ravel(), b.ravel(), fsNew.ravel()[0]

# FIXME with actual creation, but for now, just verify via file load
def pad_lowpass_create(fcNew, fsOld):
    # FIXME with actual creation, but for now, just verify via file load
    # SEE OCTAVE IMPLEMENTATION AT ~/dev/programs/octave/pad/padlowpasscreate.m
    dir_mats = '/home/pims/dev/programs/octave/pad/filters/testing'
    strFsOld = '%.1f' % fsOld
    strFcNew = '%.1f' % fcNew
    fname = 'padlowpassauto_%ssps_%shz.mat' % (strFsOld.replace('.', 'd'), strFcNew.replace('.', 'd'))
    filter_mat_file = os.path.join(dir_mats, fname)
    # if this next line errors, then LET IT ERROR because we have not implemented FIXME yet
    a, b, fsNew = load_filter_coeffs(filter_mat_file)
    return a, b, fsNew

# return low-pass filtered data
def pad_lowpass_filtfilt(x, fcNew, fsOld):
    """return low-pass filtered data"""
    a, b, fsNew = pad_lowpass_create(fcNew, fsOld)
    y = signal.filtfilt(b, a, x)
    return y

def demo():
    # ---------------------------------------------------------------------------------------------------
    # USE THE LEGACY MAT FILE
    # ---------------------------------------------------------------------------------------------------    
    #filt_mat_file = '/home/pims/dev/programs/octave/pad/filters/testing/padlowpassauto_500d0sps_6d0hz.mat'
    filt_mat_file = '/home/pims/dev/programs/octave/pad/filters/testing/padlowpassauto_500sps_5hz.mat'    
    a, b, fsNew = load_filter_coeffs(filt_mat_file)
    print b
    print a
    print fsNew

def demo2():
    a, b, fsNew = pad_lowpass_create(6.0, 500.0)
    print b, a, fsNew
    
if __name__=="__main__":
    demo2()