#!/usr/bin/env python
version = '$Id$'

import sys
import time
import subprocess
import threading

class NoLog(object):
    def info(self, s): pass
    def debug(self, s): pass
    def warning(self, s): pass
    def warn(self, s): pass
    def error(self, s): pass
    def exception(self, s): pass
    def critical(self, s): pass

class StdoutLog(object):
    def info(self, s): print s
    def debug(self, s): print s
    def warning(self, s): print s
    def warn(self, s): print s
    def error(self, s): print 'ERROR ' + s
    def exception(self, s): print 'EXCEPTION ' + s
    def critical(self, s): print 'CRITICAL ' + s
    
class Command(object):
    def __init__(self, cmd, log):
        self.cmd = cmd
        self.log = log
        self.process = None

    def run(self, timeout):
        def target():
            self.log.info( 'Thread started' )
            self.process = subprocess.Popen(self.cmd, shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            out, err = self.process.communicate()
            if err:
                self.log.error( 'here is stderr...\n' + err )
            else:
                self.log.info( 'there was no stderr' )
            self.log.info( 'here is stdout...\n' + out )
            self.log.info( 'Thread finished' )

        thread = threading.Thread(target=target)
        thread.start()

        thread.join(timeout)
        if thread.is_alive():
            self.log.warning( 'Terminating process' )
            self.process.terminate()
            thread.join()
        return self.process.returncode

def timeLogRun(command, timeoutSec, log=None):
    """
    Function that returns (returnCode, elapsedSec) from given command string.
    
    Also has timeout and logging features.
    
    Examples
    --------
    >>> retCode, elapsedSec = timeLogRun('echo start; date; sleep 2; echo done', 3, log=None)
    >>> retCode, elapsedSec<3
    (0, True)
    """
    if not log:
        log = NoLog()
    cmdObj = Command(command, log)
    tzero = time.time()
    log.info( 'START: ' + command )
    retCode = cmdObj.run(timeout=timeoutSec)
    elapsedSec = time.time() - tzero
    log.info( 'Took about %.3f seconds' % elapsedSec )
    log.info( 'Return code = %d' % retCode)
    return retCode, elapsedSec

#retCode, elapsedSec = timeLogRun('echo start; date; sleep 2; echo done', 3, log=None)
#raise SystemExit

if __name__ == "__main__":
    import doctest
    doctest.testmod()    