#!/usr/bin/env python

import numpy as np
import pandas as pd

def smart_ylims(minval, maxval):
    span = maxval - minval
    ymin = np.ceil( minval - 0.1 * span )
    ymax = np.ceil( maxval + 0.1 * span )
    return (ymin, ymax)

def round2multiple(target, n):
    if not isinstance(target, int):
        raise ValueError('target must be int')
    if n > 0:
        return np.ceil(n/float(target)) * target;
    elif n < 0:
        return np.floor(n/float(target)) * target;
    else:
        return n

# read csvfile like for JAXA plot parameters
def read_plot_params(csvfile):
    """read csvfile like for JAXA plot parameters"""
    df = pd.read_csv(csvfile)