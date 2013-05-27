#!usr/bin/env python

import wx
import random

colorEventType = wx.NewEventType()
EVT_COLOR_EVENT = wx.PyEventBinder(colorEventType, 1)

class ButtonPanel(wx.Panel):
    def __init__(self, parent, *args, **kwargs):
        wx.Panel.__init__(self, parent, *args, **kwargs)

        vsizer = wx.BoxSizer(wx.VERTICAL)
        self.rstbutt = wx.Button(self, wx.ID_ANY, label='Restore')
        self.rstbutt.Disable()
        self.Bind(wx.EVT_BUTTON, self.OnButt, self.rstbutt)
        vsizer.Add(self.rstbutt, 0, wx.ALIGN_CENTER)
        vsizer.Add((500,150), 0)
        self.SetSizer(vsizer)

    def OnButt(self, evt):
        self.SetBackgroundColour(wx.NullColor)
        self.GetParent().Refresh()
        self.rstbutt.Disable()

class ColorEvent(wx.PyCommandEvent):
    def __init__(self, evtType, id):
        wx.PyCommandEvent.__init__(self, evtType, id)
        self.color = None

    def SetMyColor(self, color):
        self.color = color

    def GetMyColor(self):
        return self.color

class MainFrame(wx.Frame):
    def __init__(self, parent, *args, **kwargs):
        wx.Frame.__init__(self, parent, *args, **kwargs)
        framesizer = wx.BoxSizer(wx.VERTICAL)
        self.panel = ButtonPanel(self, wx.ID_ANY)
        framesizer.Add(self.panel, 1, wx.EXPAND)

        menubar = wx.MenuBar()
        filemenu = wx.Menu()
        menuquit = filemenu.Append(wx.ID_ANY, '&Quit')
        menubar.Append(filemenu, 'File')
        colormenu = wx.Menu()
        switch = colormenu.Append(wx.ID_ANY, '&Switch Color')
        menubar.Append(colormenu, '&Color')
        self.SetMenuBar(menubar)

        self.Bind(wx.EVT_MENU, self.OnQuit, menuquit)
        self.Bind(wx.EVT_MENU, self.OnColor, switch)
        self.Bind(EVT_COLOR_EVENT, self.ColorSwitch)
        self.SetSizerAndFit(framesizer)

    def OnQuit(self, evt):
        self.Close()

    def OnColor(self, evt):
        colevt = ColorEvent(colorEventType, -1)
        colors = ['red', 'green', 'blue', 'white', 'black', 'pink',
            (106, 90, 205), #slate blue
            (64, 224, 208), #turquoise
            ]
        choice = random.choice(colors)
        colevt.SetMyColor(choice)
        self.GetEventHandler().ProcessEvent(colevt)
        #evt.Skip()

    def ColorSwitch(self, evt):
        color = evt.GetMyColor()
        #print(color)
        self.panel.SetBackgroundColour(color)
        self.Refresh()
        self.panel.rstbutt.Enable()

if __name__ == "__main__":
    app = wx.App()
    frame = MainFrame(None, wx.ID_ANY, title="Change Panel Color Custom Event")
    frame.Show(True)
    app.MainLoop()
