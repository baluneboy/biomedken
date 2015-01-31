#!/usr/bin/env python

import os
from pims.signal.filter import load_filter_coeffs

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

def demo():
    a, b, fsNew = pad_lowpass_create(6.0, 500.0)
    print b, a, fsNew

if __name__ == "__main__":
    demo()