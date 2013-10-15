#!/usr/bin/env python
version = '$Id$'

import sys
import time
import subprocess
import threading
    
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
        from pims.core.files.log import NoLog
        log = NoLog()
    cmdObj = Command(command, log)
    tzero = time.time()
    log.info( 'START: ' + command )
    retCode = cmdObj.run(timeout=timeoutSec)
    elapsedSec = time.time() - tzero
    log.info( 'Took about %.3f seconds' % elapsedSec )
    log.info( 'Return code = %d' % retCode)
    return retCode, elapsedSec

if __name__ == "__main__":
    import doctest
    doctest.testmod()    