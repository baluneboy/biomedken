#!/usr/bin/env python

import sys
from mutagen.id3 import ID3
import eyeD3

# 
##----------------------------------------------------------------------
def getEyeD3Tags(path):
    """read & print some info"""
    tag = eyeD3.Tag()
    tag.link(path)
    print "Artist: %s" % tag.getArtist()
    print "Album: %s" % tag.getAlbum()
    print "Title: %s" % tag.getTitle()
    return tag

def getMutagenTags(path):
    """simple read"""
    audio = ID3(path)
 
    print "Artist: %s" % audio['TPE1'].text[0]
    print "Track: %s" % audio["TIT2"].text[0]


def setMutagenTag(path):
    """simple write"""
    audio = ID3(path)
 
    print "Artist: %s" % audio['TPE1'].text[0]
    print "Track: %s" % audio["TIT2"].text[0]
    
if __name__ == '__main__':
    tag = getEyeD3Tags(sys.argv[1])
    #tag.setAlbum(u"Unknown Album")
    #tag.update()
    #tag = getEyeD3Tags(sys.argv[1])
