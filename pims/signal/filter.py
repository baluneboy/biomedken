#!/usr/bin/python

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

# return low-pass filtered data
def pad_lowpass_filtfilt(x, fcNew, fsOld):
    """return low-pass filtered data"""
    a, b, fsNew = pad_lowpass_create(fcNew, fsOld)
    y = signal.filtfilt(b, a, x)
    return y

def demo():
    mat_file = '/home/pims/dev/programs/octave/pad/filters/testing/padlowpassauto_500d0sps_6d0hz.mat'
    a, b, fsNew = load_filter_coeffs(mat_file)
    print b
    print a
    print fsNew
   
if __name__=="__main__":
    demo()