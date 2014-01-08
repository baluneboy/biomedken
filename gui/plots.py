#!/usr/bin/python

# TODO incorporate "Current GMT with AOS/LOS indicator" [updated on status bar timer?]

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.figure import Figure
from pims.gui import DUMMYDATA

# NOTE: we use matplotlibrc conventions
#import matplotlib
#print matplotlib.get_configdir()
#print matplotlib.matplotlib_fname()
#raise SystemExit

class Plot3x1(object):
    """Container class for general purpose 3x1 plot, like for xyz vs. time."""
    # it does not appear to be straightforward to subclass Figure class!?
    
    def __init__(self):
        self.fig = plt.figure()
        self.suptitle = plt.suptitle("GridSpec3x1")
        self.gs = gridspec.GridSpec(3, 1)
        self.handles = self.get_handles()
    
    def get_handles(self):
        """
        plot the data as a line series, and save the reference 
        to the plotted line series
        """
        h = {}
        x = DUMMYDATA['x']
        y = DUMMYDATA['y']
        for i in range(3):
            suffix = '%d1' % (i + 1)
            hax = plt.subplot(self.gs[i], gid='ax' + suffix)
            hline = hax.plot_date(x, y, '.-', gid='line' + suffix)[0]
            h['ax' + suffix] = hax
            h['line' + suffix] = hline
        return h

    def show_demo(self):
        for i, ax in enumerate(self.fig.axes):
            ax.text(0.5, 0.5, "ax%d1" % (i+1), va="center", ha="center")
            for tl in ax.get_xticklabels() + ax.get_yticklabels():
                tl.set_visible(False)

plotxyz = Plot3x1()
plotxyz.show_demo()
plt.show()
