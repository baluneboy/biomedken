#!/usr/bin/env python

"""Examples illustrating the use of plt.subplots().

This function creates a figure and a grid of subplots with a single call, while
providing reasonable control over how the individual plots are created.  For
very refined tuning of subplot creation, you can still use add_subplot()
directly on a new figure.
"""

# The quasi-steady acceleration environment of the space station is usually, well...boring.
# EXCEPT, for example, when the ATV-4 cargo vehicle was used to reboost the station's altitude.

import matplotlib.pyplot as plt
import numpy as np
import scipy.io

# Load ossbtmf data
mat = scipy.io.loadmat('/home/pims/Documents/MATLAB/atv4reboost.mat')

# Define main variables of function
t = np.array(mat['t'][0])
t = ( t - t[0] ) * 1440
x = np.array(mat['x'][0])
y = np.array(mat['y'][0])
z = np.array(mat['z'][0])

# Let's do this the old-fashioned way (slowly and inefficiently)
#for i in range(len(t)):
for i in range(3):
    
    # Three subplots, the axes array is 1-d
    f, axarr = plt.subplots(3, sharex=True)
    axarr[0].plot(t[0:i], x[0:i])
    axarr[0].set_title('ATV-4 Reboost', fontsize=20, fontweight='bold')
    axarr[0].axis((t[0], t[-1], -300, 300))
    axarr[0].set_ylabel(r'$X-Axis$ $(\mu g)$', fontsize=16)
    
    axarr[1].plot(t[0:i], y[0:i])
    axarr[1].axis((t[0], t[-1], -30, 30))
    axarr[1].set_ylabel(r'$Y-Axis$ $(\mu g)$', fontsize=16)
    
    axarr[2].plot(t[0:i], z[0:i])
    axarr[2].axis((t[0], t[-1], -30, 30))
    axarr[2].set_ylabel(r'$Z-Axis$ $(\mu g)$', fontsize=16)
    axarr[2].set_xlabel('Time (minutes)', fontsize=14)
    
    # The file name indicates how the image will be saved and the
    # order it will appear in the movie.  If you actually wanted each
    # graph to be displayed on the screen, you would include commands
    # such as show() and draw() here.  See the matplotlib
    # documentation for details.  In this case, we are saving the
    # images directly to a file without displaying them.
    filename = str('%03d' % i) + '.png'
    plt.savefig('/tmp/' + filename, dpi=100)

    # Let the user know what's happening.
    print 'Wrote file', filename

    # Clear the figure to make way for the next image.
    plt.clf()
