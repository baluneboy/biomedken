#!/usr/bin/env python

import time
import wx
 
from threading import Thread
from wx.lib.pubsub import Publisher

from pymouse import PyMouseEvent

########################################################################
class MouseClickEvent(PyMouseEvent):
    def __init__(self):
        PyMouseEvent.__init__(self)

    def move(self, x, y):
        #print "Mouse moved to", x, y
        Publisher().sendMessage("update", "Mouse moved to %g %g" % (x, y))
        self.pos = (x, y)

    def click(self, x, y, button, press):
        if button == 1:
            if press:
                #print "Mouse pressed at", x, y, "with button", button
                Publisher().sendMessage("update", "Mouse pressed at %g %g with button %d" % (x, y, button))
            else: # RELEASE THE MOUSE
                #print "Mouse released at", x, y, "with button", button
                pass
        else:  # Exit if any other mouse button used
            self.stop()
            wx.CallAfter(Publisher().sendMessage, "update", "Thread finished!")

########################################################################
class MyThread(Thread):
    """Test Worker Thread Class."""
 
    #----------------------------------------------------------------------
    def __init__(self):
        """Init Worker Thread Class."""
        Thread.__init__(self)
        self.start()    # start the thread
 
    #----------------------------------------------------------------------
    def run(self):
        """Run Worker Thread."""
        # This is the code executing in the new thread.
        wx.CallAfter(self.post_mouse)
 
    def post_mouse(self):
        self.mouse_click_evt = MouseClickEvent()
        self.mouse_click_evt.run()
 
    #----------------------------------------------------------------------
    def post_time(self, amt):
        """
        Send time to GUI
        """
        amtOfTime = amt + 1
        Publisher().sendMessage("update", amtOfTime)
 
########################################################################
class MyFrame(wx.Frame):
 
    #----------------------------------------------------------------------
    def __init__(self):
        wx.Frame.__init__(self, None, wx.ID_ANY, "Mouse Catcher")
        myCursor= wx.StockCursor(wx.CURSOR_CROSS)
        self.SetCursor(myCursor)        
        self.SetTransparent(200)
        self.Maximize()
        self.Layout()
 
        # Add a panel so it looks the correct on all platforms
        panel = wx.Panel(self, wx.ID_ANY)
        self.displayLbl = wx.StaticText(panel, label="Amount of time since thread started goes here")
        self.btnStart = wx.Button(panel, label="Start Thread")
        self.btnStop = wx.Button(panel, label="Stop Thread")
 
        self.btnStart.Bind(wx.EVT_BUTTON, self.on_button_start)
        self.btnStop.Bind(wx.EVT_BUTTON, self.on_button_stop)
 
        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(self.displayLbl, 0, wx.ALL|wx.CENTER, 5)
        sizer.Add(self.btnStart, 0, wx.ALL|wx.CENTER, 5)
        sizer.Add(self.btnStop, 0, wx.ALL|wx.CENTER, 5)
        panel.SetSizer(sizer)
 
        # create a pubsub receiver
        Publisher().subscribe(self.updateDisplay, "update")
 
     #----------------------------------------------------------------------
    def on_button_stop(self, event):
        """
        Stops the thread
        """
        self.displayLbl.SetLabel("Stopping Thread...")
        self.mouse_thread.stop()
        self.displayLbl.SetLabel("Mouse Thread Stopped.")        
  
    #----------------------------------------------------------------------
    def on_button_start(self, event):
        """
        Runs the mouse thread
        """
        self.mouse_thread = MyThread()
        self.displayLbl.SetLabel("Thread started!")
        #btnStart = event.GetEventObject()
        #btnStart.Disable()
        self.btnStart.Disable()
 
    #----------------------------------------------------------------------
    def updateDisplay(self, msg):
        """
        Receives data from thread and updates the display
        """
        t = msg.data
        self.displayLbl.SetLabel("%s" % t)
        self.SetTitle("%s" % t)
 
#----------------------------------------------------------------------
# Run the program
if __name__ == "__main__":
    app = wx.PySimpleApp()
    frame = MyFrame().Show()
    app.MainLoop()