#!/usr/bin/env python

import wx

class Frame(wx.Frame):
     def __init__(self):
        wx.Frame.__init__(self, None, size=(300, 300))
        myCursor= wx.StockCursor(wx.CURSOR_CROSS)
        self.SetCursor(myCursor)
        self.timer = wx.Timer(self)
        self.Bind(wx.EVT_TIMER, self.update_title)
        self.timer.Start(20)  # in milliseconds

     def update_title(self, event):
        pos = wx.GetMousePosition()
        self.SetTitle("Your mouse is at (%s, %s)" % (pos.x, pos.y))

app = wx.App(redirect=False)
top = Frame()
top.Show()
app.MainLoop()