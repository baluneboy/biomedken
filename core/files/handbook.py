#!/usr/bin/env python
"""
Utilities for handling handbook files.
"""
import os
import re
from pims.core.files.base import RecognizedFile, UnrecognizedPimsFile
from pims.core.strings.utils import underscore_as_datetime
from pims.patterns.handbookpdfs import *
from pims.core.files.pdfs.pdfjam import PdfjamCommand
from pims.core.files.log import HandbookLog
from pims.core.files.pod.templates import _HANDBOOK_TEMPLATE_ODT, _HANDBOOK_MANIFEST_TEMPLATE_ODS
from appy.pod.renderer import Renderer

# TODO for sensors like 121f03one, we can use patterns to parse further, right?
# TODO some properties can be queried from [yoda?] db with time and sensor designation, right?

class HandbookPdf(RecognizedFile):
    """
    A mixin for use alongside pims.core.files.base.RecognizedFile, which provides
    additional features for dealing with handbook files.
    """
    def __init__(self, name, pattern=_HANDBOOKPDF_PATTERN, show_warnings=False):
        super(HandbookPdf, self).__init__(name, pattern, show_warnings=show_warnings)
        self._plot_type = None
        self._page = None
        self.subtitle = self._get_subtitle()
        self._notes = None

    def __str__(self):
        s = '%s isa %s\n' % (self.name, self.__class__.__name__)   
        return s

    def __repr__(self):
        return self.__str__()
    
    def _get_pdfjam_params(self):
        """Use plot type to get pdfjam offset/scale parameters."""
        return sweet_pdfjam_params(self.plot_type)

    @property
    def plot_type(self):
        """The plot_type property (like 'gvt3' or 'spg')."""
        return self._plot_type

    @plot_type.setter
    def plot_type(self, value):
        self._plot_type = value

    #def _get_page(self):
    #    return int( self._match.group('page') )
    
    @property
    def page(self):
        """The page property (expecting single digit integer)."""
        return self._page

    @page.setter
    def page(self, value):
        self._page = int( self._match.group('page') )

    def _get_subtitle(self):
        return self._match.group('subtitle')
    
    #@property
    #def subtitle(self):
    #    """The subtitle property (like 'qualify', 'quantify', or 'ancillary')."""
    #    return self._subtitle
    #
    #@subtitle.setter
    #def subtitle(self, value):
    #    self._subtitle = self._match.group('subtitle')
    #
    #@subtitle.getter
    #def subtitle(self):
    #    return self._subtitle

    #def _get_notes(self):
    #    return self._match.group('notes') or 'empty'
    
    @property
    def notes(self):
        """The notes property."""
        return self._notes

    @notes.setter
    def notes(self, value):
        self._notes = self._match.group('notes')
    
class OssBtmfRoadmapPdf(HandbookPdf):
    """
    OSSBTMF Roadmap PDF handbook file like one of these examples:
    /tmp/1qualify_2013_10_01_08_ossbtmf_roadmap.pdf
    /tmp/2quantify_2013_10_01_08_ossbtmf_roadmap+some_notes.pdf
    /tmp/3quantify_2013_10_01_08_ossbtmf_roadmap-what.pdf    
    """
    def __init__(self, name, pattern=_OSSBTMFROADMAPPDF_PATTERN, show_warnings=False):
        super(OssBtmfRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings) # pattern is specialized for this class

        # Get command object for "jamming" PDF up/left via offset/scale
        self.pdfjam_cmd = self._get_pdfjam_cmd()
        self.pdfjam_cmdstr = str(self.pdfjam_cmd)

        # Get renderer to be run for writing imageless background odt file
        self.odt_renderer = self._get_odt_renderer()
        self.odt_renderer.run()
    
    def _get_odt_renderer(self):
        pth, fname = os.path.split(self.name)
        bname, ext = os.path.splitext(fname)
        self.odt_name = os.path.join(pth, 'build', bname + '.odt')
        page_dict = self.__dict__
        page_dict['system'] = 'SYS'
        page_dict['title'] = 'TITLE'
        return Renderer( _HANDBOOK_TEMPLATE_ODT, page_dict, self.odt_name )
    
    def _get_pdfjam_cmd(self):
        xoffset, yoffset = -4.75, 1.0
        scale = 0.88
        orient = 'landscape'
        return HandbookPdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient) # , log=log)

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
        return HandbookPdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient) # , log=log)
    
    @property
    def axis(self): return self._match.group('axis')

class HandbookPdfjamCommand(PdfjamCommand):

    def __init__(self, *args, **kwargs):
        kwargs['log'] = HandbookLog()
        self.subdir = 'build'
        super(HandbookPdfjamCommand, self).__init__(*args, **kwargs)
        
    def get_outfile(self):
        tmp = super(HandbookPdfjamCommand, self).get_outfile()
        pth, fn = os.path.split(tmp)
        return os.path.join(pth, self.subdir, fn)

def demo():
    import os
    from pims.core.files.handbook import OssBtmfRoadmapPdf, SpgxRoadmapPdf, HandbookPdf
    from pims.core.files.utils import guess_file
    
    log = HandbookLog()
    
    pth = '/home/pims/Documents/test/'
    names = [
    '3ancillary_yes.pdf',
    'trash_stupid.txt',
    '1qualify_2013_10_10_00_00_00.000_121f03one_spgs_roadmaps142_amazing.pdf',
    '2quantify_2013_10_01_00_ossbtmf_roadmap.pdf',
    ]
    files = [os.path.join(pth,n) for n in names]
    files.sort()

    filetypes = [ OssBtmfRoadmapPdf, SpgxRoadmapPdf, HandbookPdf ]
    print 'Working on sourceDir %s' % pth
    for f in files:
        try:
            hbf = guess_file(f, filetypes=filetypes, show_warnings=False)
            log.hbook.info( hbf._get_dict() ) # this dict should help with ODT creation
            if hasattr(hbf, 'pdfjam_cmd'):
                log.pdf.info(hbf.pdfjam_cmdstr)
                hbf.pdfjam_cmd.run(log=log.pdf)
                flag = 'ok'
            else:
                flag = 'xx'
            print flag, os.path.basename(f)
        except UnrecognizedPimsFile:
            print 'SKIPPED unrecognized file'

if __name__ == '__main__':
    demo()            