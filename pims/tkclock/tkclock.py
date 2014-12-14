#!/usr/bin/env python

"""use Tkinter to show a digital clock"""

import time
import datetime
from Tkinter import *
from pims.tkclock.geometry import TkGeometryIterator

cross_hours, dt_minutes = 8.5, 5
w, h = 350, 100
x, y = 0, 450
tgi = TkGeometryIterator(cross_hours, dt_minutes, w, h, x, y, sound_on=True)
root = tgi.root
screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()
time1 = ''
clock = Label(root, font=('arial', 80, 'bold'), bg='white')
clock.pack(fill=BOTH, expand=1)

def tick():
    global time1, dt1
    # get the current local time from the PC
    time2 = time.strftime('%H:%M:%S')
    # if time string has changed, update it
    if time2 != time1:
        time1 = time2
        clock.config(text=time2)
        if time2[-1] in ['0', '2', '4' , '6', '8']:
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