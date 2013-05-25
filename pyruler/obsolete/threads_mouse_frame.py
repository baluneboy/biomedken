#!/usr/bin/env python

import wx
import os, time
import threading, Queue
from pymouse import PyMouseEvent

class Frame(wx.Frame):
    def __init__(self):
        wx.Frame.__init__(self, None, size=(300, 300))
        self.align_to_bottom_right()
        self.timer = wx.Timer(self)
        self.Bind(wx.EVT_TIMER, self.update_title)
        self.timer.Start(40)  # in miliseconds

    def align_to_bottom_right(self):
        dw, dh = wx.DisplaySize()
        w, h = self.GetSize()
        x = dw - w
        y = dh - h
        self.SetPosition((x, y))

    def update_title(self, event):
        pos = wx.GetMousePosition()
        self.SetTitle("Your mouse is at (%s, %s)" % (pos.x, pos.y))

class MouseClickEvent(PyMouseEvent):
    def __init__(self):
        PyMouseEvent.__init__(self)

    def move(self, x, y):
        pass
        #print "Mouse moved to", x, y
        #self.pos = (x, y)

    def click(self, x, y, button, press):
        if button == 1:
            if press:
                print "Mouse pressed at", x, y, "with button", button
            else:
                print "Mouse released at", x, y, "with button", button
        else:  # Exit if any other mouse button used
            self.stop()

class WorkerThread(threading.Thread):
    """ A worker thread that takes directory names from a queue, finds all
        files in them recursively and reports the result.

        Input is done by placing directory names (as strings) into the
        Queue passed in action_q.

        Output is done by placing tuples into the Queue passed in result_q.
        Each tuple is (thread name, action, [list of files]).

        Ask the thread to stop by calling its join() method.
    """
    def __init__(self, action_q, result_q):
        super(WorkerThread, self).__init__()
        self.action_q = action_q
        self.result_q = result_q
        self.stoprequest = threading.Event()

    def run(self):
        # As long as we weren't asked to stop, try to take new tasks from the
        # queue. The tasks are taken with a blocking 'get', so no CPU
        # cycles are wasted while waiting.
        # Also, 'get' is given a timeout, so stoprequest is always checked,
        # even if there's nothing in the queue.
        while not self.stoprequest.isSet():
            try:
                action = self.action_q.get(True, 0.05)
                results = list(self._results_from_generator(action))
                self.result_q.put( (self.name, action, results) )
            except Queue.Empty:
                continue

    def join(self, timeout=None):
        self.stoprequest.set()
        super(WorkerThread, self).join(timeout)

    def _results_from_generator(self, action):
        """ Given a directory name, yields the names of all files (not dirs)
            contained in this directory and its sub-directories.
        """
        if os.path.isdir(action):
            for path, dirs, files in os.walk(action):
                for file in files:
                    yield os.path.join(path, file)
        elif action == 'mouse':
            mouse_click_evt = MouseClickEvent()
            mouse_click_evt.run()
            for letter in 'hi there from mouse action':
                yield letter
        elif action == 'frame':
            app = wx.App(redirect=False)
            top = Frame()
            top.Show()
            app.MainLoop()
            for letter in 'hello from frame':
                yield letter

def is_okay(action):
    if action in ['mouse','frame'] or os.path.isdir(action):
        return True
    else:
        print 'IGNORING UNHANDLED ACTION %s' % action
        return False

def main(args):
    # Create a single input and a single output queue for all threads.
    action_q = Queue.Queue()
    result_q = Queue.Queue()

    # Create the "thread pool"
    pool = [WorkerThread(action_q=action_q, result_q=result_q) for i in range(4)]

    # Start all threads
    for thread in pool:
        thread.start()

    # Give the workers some work to do
    work_count = 0
    for action in args:
        if is_okay(action):
            work_count += 1
            action_q.put(action)

    print 'Assigned %s actions to workers' % work_count

    # Now get all the results
    while work_count > 0:
        # Blocking 'get' from a Queue.
        result = result_q.get()
        print 'From action %s (thread %s) we have %s messages' % ( result[1], result[0], len(result[2]) )
        work_count -= 1

    # Ask threads to die and wait for them to do it
    for thread in pool:
        thread.join()

if __name__ == '__main__':
    import sys
    main(sys.argv[1:])
