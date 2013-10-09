#!/usr/bin/python

from pims.core.files.base import StupidRecognizedFile
from pims.core.files.handbook import OssBtmfRoadmapPdf, SpgxRoadmapPdf, HandbookFile
from pims.core.files.utils import guess_file

if __name__ == '__main__':

    #hbf = SpgxRoadmapPdf('/tmp/1qualify_2013_10_01_16_00_00.000_121f02ten_spgs_roadmaps500p9_my_note.pdf')
    #print hbf
    #print hbf.asDict()
    #raise SystemExit
    #
    #hbf = OssBtmfRoadmapPdf('/tmp/2quantify_2013_10_01_08_ossbtmf_roadmap.pdf')
    #print hbf
    #print hbf.asDict()
    #raise SystemExit
    #
    #hbf = HandbookFile('/tmp/1qualify_yes.pdf')
    #print hbf
    #print hbf.asDict()
    #raise SystemExit
    #
    #srf = StupidRecognizedFile('/tmp/trash_stupid.txt')
    #print srf
    #raise SystemExit

    files = [
    '/tmp/1qualify_yes.pdf',
    '/tmp/trash_stupid.txt',
    '/tmp/2quantify_2013_10_01_08_ossbtmf_roadmap.pdf',
    '/tmp/1qualify_2013_10_01_16_00_00.000_121f02ten_spgs_roadmaps500p9_my_note.pdf',
    ]

    filetypes = [ OssBtmfRoadmapPdf, SpgxRoadmapPdf, HandbookFile ]

    for f in files:
        hbf = guess_file(f, filetypes=filetypes, show_warnings=False)
        if hbf.recognized:
            print '~'*len(hbf.name)
            print hbf.name
            print hbf.__class__.__name__
            print hbf.asDict()
