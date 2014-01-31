#!/usr/bin/python

import pyinotify

#### The watch manager stores the watches and provides operations on watches
###wm = pyinotify.WatchManager()
###mask = pyinotify.IN_DELETE | pyinotify.IN_CREATE  # watched events

def quick_check(notifier):
      assert notifier._timeout is not None, 'Notifier must be constructed with a short timeout'
      notifier.process_events()
      while notifier.check_events():  #loop in case more events appear while we are processing
            notifier.read_events()
            notifier.process_events()

class SampleEventHandler(pyinotify.ProcessEvent):
    def process_IN_CREATE(self, event):
        print "Creating:", event.pathname

    def process_IN_DELETE(self, event):
        print "Removing:", event.pathname

class NewJaxaFileEventHandler(pyinotify.ProcessEvent):
    def process_IN_CREATE(self, event):
        if event.pathname == '/tmp/newtrash.txt':
            print "HEY, Creating:", event.pathname
        else:
            print "Creating:", event.pathname
            
    def process_IN_DELETE(self, event):
        print "Removing:", event.pathname

class NewJaxaFileNotifier(object):

    def __init__(self, watch_dir='/tmp', watch_fname='trash.txt', handler=NewJaxaFileEventHandler, timeout=10):
        # The watch manager stores the watches and provides operations on watches
        self.watch_dir = watch_dir
        self.watch_fname = watch_fname
        self.wm = pyinotify.WatchManager()
        self.handler = handler(self.watch_fname)
        self.mask =  pyinotify.IN_DELETE|pyinotify.IN_CREATE # watched events
        self.timeout = timeout
        self.notifier =  pyinotify.Notifier(self.wm, self.handler, timeout=self.timeout)
        self.wdd = self.wm.add_watch(self.watch_dir, self.mask, rec=False)

    def quick_check(self):
      assert self.notifier._timeout is not None, 'Notifier must be constructed with a short timeout'
      self.notifier.process_events()
      while self.notifier.check_events():  #loop in case more events appear while we are processing
            self.notifier.read_events()
            self.notifier.process_events()

def demo():
    import time
    jaxa_notifier = NewJaxaFileNotifier()
    for i in range(4):
        # To check for events periodically instead of blocking, use short timeout value
        ###notifier = pyinotify.Notifier(wm, handler, timeout=10)
        ###quick_check(notifier)
        jaxa_notifier.quick_check()
        print i, 'sleeping',
        time.sleep(5)
        print 'wake'

if __name__ == "__main__":
    demo()