#!/usr/bin/python

from pims.core.files.base import StupidRecognizedFile
from pims.core.files.handbook import OssBtmfRoadmapPdf, SpgxRoadmapPdf, HandbookPdf
from pims.core.files.utils import guess_file

from pims.utils.fractions import Fraction
from pims.core.files.handbook import PdfjamProperty
print PdfjamProperty( Fraction(1,2) ).value
print PdfjamProperty( 1.234 ).value
print PdfjamProperty( '5.6789' ).value
print PdfjamProperty( '8' ).value
print PdfjamProperty( 9 ).value
#raise SystemExit

if __name__ == '__main__':

    files = [
    '/tmp/1qualify_yes.pdf',
    '/tmp/trash_stupid.txt',
    '/tmp/2quantify_2013_10_01_08_ossbtmf_roadmap.pdf',
    '/tmp/1qualify_2013_10_01_16_00_00.789_121f02ten_spgs_roadmaps500p9_my_note.pdf',
    ]

    filetypes = [ OssBtmfRoadmapPdf, SpgxRoadmapPdf, HandbookPdf ]

    for f in files:
        hbf = guess_file(f, filetypes=filetypes, show_warnings=False)
        if hbf.recognized:
            print '~'*len(hbf.name)
            print hbf
