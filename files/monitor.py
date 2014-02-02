#!/usr/bin/python

import pyinotify

# process transient file
class ProcessTransientFile(pyinotify.ProcessEvent):
    """process transient file"""
    
    def process_IN_CREATE(self, event):
        print event.pathname, ' -> creating'

    def process_IN_DELETE(self, event):
        print event.pathname, ' -> deleting'

    def process_IN_MODIFY(self, event):
        print event.pathname, ' -> modifying'

# JaxaFileHandler with quick_check method to see if we created or deleted file of interest
class JaxaFileHandler(object):
    """JaxaFileHandler with quick_check method to see if we created or deleted file of interest"""

    def __init__(self, watch_file='/tmp/trash.txt', handler=ProcessTransientFile, timeout=3):
        # The watch manager stores the watches and provides operations on watches
        self.watch_file = watch_file
        self.handler = handler
        self.wm = pyinotify.WatchManager()
        self.mask =  pyinotify.IN_DELETE|pyinotify.IN_CREATE|pyinotify.IN_MODIFY # watched events
        self.timeout = timeout
        self.notifier =  pyinotify.Notifier(self.wm, timeout=self.timeout)
        self.wm.watch_transient_file(self.watch_file, self.mask, self.handler)

    def quick_check(self):
        assert self.notifier._timeout is not None, 'Notifier must be constructed with a short timeout'
        self.notifier.process_events()
        while self.notifier.check_events():  #loop in case more events appear while we are processing
            self.notifier.read_events()
            self.notifier.process_events()

def demo():
    import time
    jaxa_file_handler = JaxaFileHandler()
    for i in range(9):
        jaxa_file_handler.quick_check()
        time.sleep(2)

if __name__ == "__main__":
    demo()

# apt-get install inotify-tools
# DIR=/tmp/p; while RES=$(inotifywait -e create $DIR --format %f .); do echo RES is $RES at `date`; done