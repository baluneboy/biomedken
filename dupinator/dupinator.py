#! /usr/bin/python

# dupinator.py [original]
# script by Bill Bumgarner: see
# http://www.pycs.net/bbum/2004/12/29/
#
# Updated by Andrew Shearer on 2004-12-31: see
# http://www.shearersoftware.com/personal/weblog/2005/01/14/dupinator-ii
#
# Updated by Ken Hrovat on 2010-11-27 to use modular approach
# FileBySizer can be a generic class of itself.
# PotentialDupeFinder & RealDupeFinder code should be folded under base class called Dupinator.

# TO DO
# dupinator listing for /Users/ken's top 3 extensions (mostly mp3, m4a?)
# use cygwin to take action on dupinator output listing to consolidate dalyuser/ken accts
# dupinator for ALL locations of zmusic, zunage, mp3 & m4a file locations
# what is md5sum of zero byte files
# columns for dupinator listing output:
#  - number of path separators
#  - last [max of 3 | count - 1forbasename] subdirs -- exclude basename
#  - basename
#  - mp3/m4a tag#1 (artist)
#  - mp3/m4a tag#2 (title)
#  - mp3/m4a tag#: (etc.)

import os
import sys
import stat
import md5
from cygwin_utils import cygpath

#Define exceptions
class DupinatorError(Exception): pass
class DoesNotExistError(DupinatorError): pass

class FileBySizer(object):
    """ FileBySizer class for directory/file walk below basePath. """    

    def __init__(self, basePath=os.getcwd(), skipList=['Thumbs','.DS_Store'], minBytes=100):
        if not os.path.isdir(basePath):
            raise DoesNotExistError, "basePath %s does NOT exist" % basePath
        else:
            self.basePath = os.path.abspath(basePath)
        self.skipList = skipList
        self.minBytes = minBytes
        self.filesBySize = self.getFilesBySize()

    def __str__(self):
        c = self.__class__.__name__
        s = '\n%s (%d files)' % (c, len(self.filesBySize))
        s += "\n ... basePath = '%s'" % self.basePath
        s += "\n ... skipList = ["
        for i in self.skipList:
            s += " '%s'," % i
        if s[-1] == ',':
            s = s[0:-1]
        s += ' ]'
        return s
    
    def walker(self, arg, dirname, fnames):
        d = os.getcwd()
        os.chdir(dirname)
        try:
            #FIXME: for robust handling of "skipList" input arg 
            #fnames.remove('Thumbs')
            fnames = [name for name in fnames if name!=".DS_Store" and name!="Thumbs"]
        except ValueError:
            pass        
        for f in fnames:
            if not os.path.isfile(f) or os.path.islink(f):
                continue
            size = os.stat(f)[stat.ST_SIZE]
            if size < self.minBytes:
                continue
            if self.filesBySize.has_key(size):
                a = self.filesBySize[size]
            else:
                a = []
                self.filesBySize[size] = a
            a.append(os.path.join(dirname, f))
        os.chdir(d)

    def getFilesBySize(self):
        """ the crux does directory walk gathering files by size
        """
        self.filesBySize = {}
        for x in sys.argv[1:]:
            d = os.path.normpath(x)
            print 'Scanning directory "%s"....' % d
            os.path.walk(d, self.walker, self.filesBySize)
        return self.filesBySize

class PotentialDupeFinder(object):
    """ A class for finding potential duplicate files. """    

    def __init__(self, fbs, requireEqualNames=False, firstScanBytes=8192):
        self.filesBySize = fbs.filesBySize
        self.requireEqualNames = requireEqualNames
        self.firstScanBytes = firstScanBytes
        self.dupes, self.potentialDupes, self.potentialCount = self.findPotentialDupes()

    def __str__(self):
        c = self.__class__.__name__
        s = '\n%s (%d files)' % (c, len(self.filesBySize))
        s += "\n ... basePath = '%s'" % self.basePath
        s += "\n ... skipList = ["
        for i in self.skipList:
            s += " '%s'," % i
        if s[-1] == ',':
            s = s[0:-1]
        s += ' ]'
        return c

    def findPotentialDupes(self):
        print 'Finding potential dupes...'
        dupes = [] # ashearer
        potentialDupes = []
        potentialCount = 0
        sizes = self.filesBySize.keys()
        sizes.sort()
        for k in sizes:
            inFiles = self.filesBySize[k]
            hashes = {}
            if len(inFiles) is 1: continue
            print 'Testing %d files of size %d...' % (len(inFiles), k)
            if self.requireEqualNames:
                for fileName in inFiles:
                    hashes.setdefault(os.path.basename(fileName), []).append(fileName)
                inFiles = []
                for nameGroup in hashes.values():
                    if len(nameGroup) > 1:
                        inFiles.extend(nameGroup)
                hashes = {}
            for fileName in inFiles:
                if not os.path.isfile(fileName):
                    continue
                aFile = file(fileName, 'r')
                hasher = md5.new(aFile.read(self.firstScanBytes))
                hashValue = hasher.digest()
                if hashes.has_key(hashValue):
                    hashes[hashValue].append(fileName)
                else:
                    hashes[hashValue] = [fileName]
                aFile.close()
            outFileGroups = [fileGroup for fileGroup in hashes.values() if len(fileGroup) > 1] # ashearer
            if k <= self.firstScanBytes:   # we already scanned to whole file; put into definite dups list (ashearer)
                dupes.extend(outFileGroups)
            else:
                potentialDupes.extend(outFileGroups)
            potentialCount = potentialCount + len(outFileGroups)
        #del filesBySize
        
        print 'Found %d sets of potential dupes...' % potentialCount
        return dupes, potentialDupes, potentialCount

class RealDupeFinder(object):
    """ Scan for real duplicates. """    

    def __init__(self, potDupeFinder):
        self.dupes = potDupeFinder.dupes
        self.potentialDupes = potDupeFinder.potentialDupes
        self.getRealDupes()

    def __str__(self):
        c = self.__class__.__name__
        s = '\n%s (%d files)' % (c, len(self.filesBySize))
        s += "\n ... basePath = '%s'" % self.basePath
        s += "\n ... skipList = ["
        for i in self.skipList:
            s += " '%s'," % i
        if s[-1] == ',':
            s = s[0:-1]
        s += ' ]'
        return c

    def getRealDupes(self):
        print 'Scanning for real dupes...'
        for aSet in self.potentialDupes:
            hashes = {}
            for fileName in aSet:
                print 'Scanning file "%s"...' % fileName
                aFile = file(fileName, 'r')
                hasher = md5.new()
                while True:
                    r = aFile.read(4096)
                    if not len(r):
                        break
                    hasher.update(r)
                aFile.close()
                hashValue = hasher.digest()
                if hashes.has_key(hashValue):
                    hashes[hashValue].append(fileName)  # ashearer
                else:
                    hashes[hashValue] = [fileName] #ashearer
            outFileGroups = [fileGroup for fileGroup in hashes.values() if len(fileGroup) > 1] # ashearer
            self.dupes.extend(outFileGroups)

class DupeHandler(object):
    """ Handle duplicate files. """    

    def __init__(self, dupes):
        self.dupes = dupes
        self.handleDupes()

    def __str__(self):
        c = self.__class__.__name__
        s = '\n%s (%d files)' % (c, len(self.filesBySize))
        s += "\n ... basePath = '%s'" % self.basePath
        s += "\n ... skipList = ["
        for i in self.skipList:
            s += " '%s'," % i
        if s[-1] == ',':
            s = s[0:-1]
        s += ' ]'
        return c

    def handleDupes(self):
        i = 0
        bytesSaved = 0
        for d in self.dupes:
            print '## "%s"' % cygpath(d[0])
            for f in d[1:]:
                i = i + 1
                print 'rm "%s"' % cygpath(f)
                bytesSaved += os.path.getsize(f)
                #os.remove(f)
            print
        print "We would have saved %.1fM; %d file(s) duplicated." % (bytesSaved/1024.0/1024.0,len(self.dupes))

class Dupinator(object):
    """ Dupinator class to serve as base for like DupinatorMusic. """

    def __init__(self, basePath=os.getcwd(), skipList=['Thumbs','.DS_Store'], minBytes=100):
        fileBySizeObj = FileBySizer(basePath=basePath,skipList=skipList,minBytes=minBytes)
        potentialDupeObj = PotentialDupeFinder(fileBySizeObj)
        realDupeObj = RealDupeFinder(potentialDupeObj)
        self.dupes = realDupeObj.dupes
        DupeHandler(self.dupes)

    def __str__(self):
        c = self.__class__.__name__
        s = '\n%s (%d files)' % (c, len(self.filesBySize))
        s += "\n ... basePath = '%s'" % self.basePath
        s += "\n ... skipList = ["
        for i in self.skipList:
            s += " '%s'," % i
        if s[-1] == ',':
            s = s[0:-1]
        s += ' ]'
        return c

if __name__ == '__main__':
    basePath = sys.argv[1]
    Dupinator(basePath=basePath)
    sys.exit(0)