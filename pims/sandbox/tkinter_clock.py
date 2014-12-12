#!/usr/bin/env python

"""use Tkinter to show a digital clock"""

from Tkinter import *
import time

root = Tk()
time1 = ''
clock = Label(root, font=('courier', 80, 'bold'), bg='white')
clock.pack(fill=BOTH, expand=1)
def tick():
    global time1
    # get the current local time from the PC
    time2 = time.strftime('%H:%M:%S')
    # if time string has changed, update it
    if time2 != time1:
        time1 = time2
        clock.config(text=time2)
        if time2.endswith('5'):
            clock.config(bg='red')
            root.geometry('600x200+140+280')
        else:
            clock.config(bg='white')
    # calls itself every 200 milliseconds
    # to update the time display as needed
    # could use >200 ms, but display gets jerky
    clock.after(200, tick)
tick()
root.mainloop()