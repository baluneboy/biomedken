#!/usr/bin/env python
version = '$Id$'

import os
import glob
import sys
import shutil
from recipes_fileutils import fileAgeDays

MAXDAYS = 5

def isVeryOld(f):
    return fileAgeDays(f) > MAXDAYS
    
def isOld(f):
    return fileAgeDays(f) > 2

def moveToRecent(f):
    shutil.move(f, '/misc/yoda/www/plots/user/buffer/recent/')

def removeVeryOld(f):
    os.remove(f)

def processPath(wildPath, criteria, disposition):
    count = 0
    for f in glob.glob(wildPath):
        if criteria(f):
            disposition(f)
            count += 1
    return count

def main():
    numMoved = processPath('/misc/yoda/www/plots/user/buffer/*.jpg', isOld, moveToRecent)
    numRemoved = processPath('/misc/yoda/www/plots/user/buffer/recent/*.jpg', isVeryOld, removeVeryOld)
    return 'moved %d files and removed %d files' % (numMoved, numRemoved)

if __name__ == '__main__':
    print main()
    sys.exit(0)
