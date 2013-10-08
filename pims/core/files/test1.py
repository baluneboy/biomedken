#!/usr/bin/python

from pims.core.files.base import StupidRecognizedFile
from pims.core.files.handbook import HandbookFile, OssBtmfRoadmapPdf

if __name__ == '__main__':

    print '~'*44

    a = OssBtmfRoadmapPdf('/tmp/2quantify_2013_10_01_08_ossbtmf_roadmap.pdf')
    print a
    print '~'*44
    
    #raise SystemExit

    hbf = HandbookFile('/tmp/1qualify_yes.pdf', '.*(\d{1})(qualify|quantify|ancillary)_.*\.pdf$')
    print hbf
    print hbf.asDict()
    print hbf.page
    print hbf.subtitle
    print len(hbf)
    
    #raise SystemExit

    pf = StupidRecognizedFile('/tmp/trash_stupid.txt')
    print pf
    print pf.asDict()
    print pf.type()
    print len(pf)
    print '~'*44
    
    #raise SystemExit