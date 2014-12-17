#!/usr/bin/env python

"""use Tkinter to show a digital clock"""

import time
import datetime
import numpy as np
from Tkinter import *
from pims.tkclock.geometry import TkGeometryIterator

is_dst = time.localtime().tm_isdst

cross_hours, dt_minutes = 8.5, 5
w, h = 350, 100
x, y = 0, 450
tgi = TkGeometryIterator(cross_hours, dt_minutes, w, h, x, y, sound_on=True)
root = tgi.root
screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()
time1 = ''
clock = Label(root, font=('arial', 60, 'bold'), bg='white')
clock.pack(fill=BOTH, expand=1)

def map_hms2x(xmin, xmax, tlocal_min, tlocal_max):
    t = np.linspace(0, 20, 11025*20, endpoint=False)

def tick():
    global time1, dt1
    # get the current local time from the PC
    tnow = time
    time2 = tnow.strftime('%H:%M:%S')
    # if time string has changed, update it
    # label update should be once per second
    if time2 != time1:
        time1 = time2
        clock.config(text=time2)
        #if time2[-4:] in ['0:00', '5:00']:
        if time2 == '11:30:00':
            root.title('RESET')
            clock.config(bg='blue')
            tgi.reset()
            xnew = tgi.xnext()
            tgi.set_x( xnew )
            root.geometry(tgi)
        elif time2[-1:] in ['0', '1', '2']:
            clock.config(bg='red')
            xnew = tgi.xnext()
            tgi.set_x( xnew )
            root.geometry(tgi)
            dt2 = datetime.datetime.now()
            elapsed_sec = (dt2 - dt1).total_seconds()
            total_px = tgi.x
            px_per_sec = total_px / elapsed_sec
            root.title( 'avg=%.1fpx/s' %  px_per_sec)
        else:
            clock.config(bg='white')
            root.geometry(tgi)
    # calls itself every 200 milliseconds
    # to update the time display as needed
    # could use >200 ms, but display gets jerky
    clock.after(200, tick)

dt1 = datetime.datetime.now()   
tick()
root.mainloop()