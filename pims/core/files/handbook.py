#!/usr/bin/env python
"""
Utilities for handling handbook files.
"""
import re
from pims.core.files.base import RecognizedFile, UnrecognizedPimsFile
from pims.core.strings.utils import underscore_as_datetime
from pims.patterns.handbookpdfs import *
from pims.core.files.pdfs.pdfjam import PdfjamCommand

# TODO plotType implies pdfjam offset/scale, right?
# TODO breakout offset/scale to xoffset, yoffset, and scale floats
# TODO for sensors like 121f03one, we can use patterns to parse further, right?
# TODO some properties can be queried from [yoda?] db with time and sensor designation, right?

class SpgPdfjamCommand(PdfjamCommand):
    def __init__(self, infile, log=None):
        xoffset, yoffset = -3, 1.0
        scale = 0.75
        orient = 'landscape'
        super(SpgPdfjamCommand, self).__init__(infile, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient, log=log)

class HandbookPdf(RecognizedFile):
    """
    A mixin for use alongside pims.core.files.base.RecognizedFile, which provides
    additional features for dealing with handbook files.
    """
    def __init__(self, name, pattern=_HANDBOOKPDF_PATTERN, show_warnings=False):
        super(HandbookPdf, self).__init__(name, pattern, show_warnings=show_warnings)

    def __str__(self):
        s = '%s isa %s\n' % (self.name, self.__class__.__name__)   
        return s

    def __repr__(self):
        return self.__str__()
    
    def _get_pdfjam_params(self):
        """ Use plot type to get pdfjam offset/scale parameters. """
        return sweet_pdfjam_params(self.plot_type)

    @property
    def plot_type(self): return None            

    @property
    def page(self): return int( self._match.group('page') )

    @property
    def subtitle(self): return self._match.group('subtitle')

    @property
    def notes(self): return self._match.group('notes') or 'empty'
        
class OssBtmfRoadmapPdf(HandbookPdf):
    """
    OSSBTMF Roadmap PDF handbook file like one of these examples:
    /tmp/1qualify_2013_10_01_08_ossbtmf_roadmap.pdf
    /tmp/2quantify_2013_10_01_08_ossbtmf_roadmap+some_notes.pdf
    /tmp/3quantify_2013_10_01_08_ossbtmf_roadmap-what.pdf    
    """
    def __init__(self, name, pattern=_OSSBTMFROADMAPPDF_PATTERN, show_warnings=False):
        super(OssBtmfRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings) # pattern is specialized for this class
        self.pdfjam_cmd = self._get_pdfjam_cmd()
        self.pdfjam_cmdstr = str(self.pdfjam_cmd)
        
    def _get_pdfjam_cmd(self):
        xoffset, yoffset = -4.75, 1.0
        scale = 0.88
        orient = 'landscape'
        return PdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient) # , log=log)

    @property
    def timestr(self): return self._match.group('timestr')

    @property
    def datetime(self): return underscore_as_datetime(self.timestr)

    @property
    def sensor(self): return self._match.group('sensor')

    @property
    def system(self): return 'MAMS'

    @property
    def sample_rate(self): return 0.0625

    @property
    def cutoff(self): return 0.01
    
    @property
    def plot_type(self): return 'gvt3'
    
    @property
    def location(self): return 'LAB1O2, ER1, Lockers 3,4' # FIXME if MAMS OSS ever moves

class SpgxRoadmapPdf(OssBtmfRoadmapPdf):
    """
    Spectrogram Roadmap PDF handbook file like "/tmp/1qualify_2013_10_01_16_00_00.000_121f02ten_spgs_roadmaps500.pdf"
    """
    def __init__(self, name, pattern=_SPGXROADMAPPDF_PATTERN, show_warnings=False):
        super(SpgxRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings)
        
    def _get_pdfjam_cmd(self):
        xoffset, yoffset = -3, 1.0
        scale = 0.72
        orient = 'landscape'
        return PdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient) # , log=log)
    
    @property
    def axis(self): return self._match.group('axis')


# Decorator for convenience
def add_squiggles(fn):
    def new(*args):
        print "~" * len(args[0])
        return fn(*args)
    return new

# You could also nest decorators in declaration order:
#    add_banner(add_squiggles(print_fname('$'*33)))
# when "add_banner" is above "add_squiggles"
@add_squiggles
def print_fname(f): print f

if __name__ == '__main__':

    from pims.core.files.handbook import OssBtmfRoadmapPdf, SpgxRoadmapPdf, HandbookPdf
    from pims.core.files.utils import guess_file
    from pims.core.files.log import demo_log
    
    files = [
    '/tmp/1qualify_yes.pdf',
    '/tmp/trash_stupid.txt',
    '/tmp/1qualify_2013_10_01_00_ossbtmf_roadmap.pdf',
    '/tmp/2qualify_2013_10_01_16_00_00.789_121f02ten_spgs_roadmaps500p9_empty_file.pdf',
    ]

    filetypes = [ OssBtmfRoadmapPdf, SpgxRoadmapPdf, HandbookPdf ]
    for f in files:
        print_fname(f)
        try:
            hbf = guess_file(f, filetypes=filetypes, show_warnings=False)
            print hbf._get_dict() # this should help with ODT creation
            if hasattr(hbf, 'pdfjam_cmd'):
                #print hbf.pdfjam_cmdstr
                logDemo = demo_log('/tmp/trashdemo.log')
                hbf.pdfjam_cmd.run(log=logDemo)
            else:
                print 'no pdfjam_cmd to run'
        except UnrecognizedPimsFile:
            print 'SKIPPED unrecognized file'
            