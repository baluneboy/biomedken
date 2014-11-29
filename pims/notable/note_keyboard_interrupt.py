#!/usr/bin/env python

"""handle keyboard interrupt, Ctrl-C, via 2 approaches"""

import sys
import time
import signal
import datetime

def signal_handler(signum, frame):
    print "\nThis is the custom interrupt handler.  Bye!"
    sys.exit(3)

def long_running_process():
    while True:
        print datetime.datetime.now(), " whenever, type Ctrl-C to interrupt..."
        time.sleep(1)

def main_one():
    # try/catch approach
    try:
        print 'use try/catch approach:'
        long_running_process()   
    except KeyboardInterrupt:
        print "\ninterrupt received, no custom handler, proceeding..."
    
    # or you can use a custom handler
    signal.signal(signal.SIGINT, signal_handler)
    print 'use custom handler approach:'
    long_running_process()

def main_two():

    data_for_signal_handler = 10

    def internal_signal_handler(*args):
        print
        print data_for_signal_handler
        sys.exit(4)

    signal.signal(signal.SIGINT, internal_signal_handler) # Or whatever signal

    while True:
        data_for_signal_handler += 1
        print datetime.datetime.now(), "type Ctrl-C to interrupt..."
        time.sleep(1)

if __name__ == '__main__':
    #main_one()
    main_two()