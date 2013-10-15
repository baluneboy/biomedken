#!/usr/bin/env python
"""
Utilities for handling handbook files.
"""
import os
import re
import datetime
from pims.core.files.base import RecognizedFile, UnrecognizedPimsFile
from pims.core.strings.utils import underscore_as_datetime, title_case_special, sensor_tuple
from pims.core.files.utils import guess_file
from pims.patterns.handbookpdfs import *
from pims.core.files.utils import listdir_filename_pattern
from pims.core.files.pdfs.pdfjam import PdfjamCommand, PdfjoinCommand
from pims.core.files.log import HandbookLog
from pims.core.files.pod.templates import _HANDBOOK_TEMPLATE_ODT
from pims.core.files.pdfs.pdftk import PdftkCommand, convert_odt2pdf
from appy.pod.renderer import Renderer
import shutil

# TODO DBQ properties can be queried from [yoda?] db with time and sensor designation, right?

class HandbookPdf(RecognizedFile):
    """
    A mixin for use alongside pims.core.files.base.RecognizedFile, which provides
    additional features for dealing with handbook files.
    """
    def __init__(self, name, pattern=_HANDBOOKPDF_PATTERN, show_warnings=False):
        super(HandbookPdf, self).__init__(name, pattern, show_warnings=show_warnings)
        self.plot_type = self._get_plot_type()
        self.page = self._get_page()
        self.subtitle = self._get_subtitle()
        self.notes = self._get_notes()

    def __str__(self): return '%s isa %s\n' % (self.name, self.__class__.__name__)   

    def __repr__(self): return self.__str__()
   
    def _get_page(self): return int( self._match.group('page') )

    def _get_subtitle(self): return title_case_special( self._match.group('subtitle') )

    def _get_notes(self): return self._match.group('notes') or 'empty'

    def _get_plot_type(self): return _PLOTTYPES['']
    
class OssBtmfRoadmapPdf(HandbookPdf):
    """
    OSSBTMF Roadmap PDF handbook file like one of these examples:
    /tmp/1qualify_2013_10_01_08_ossbtmf_roadmap.pdf
    /tmp/2quantify_2013_10_01_08_ossbtmf_roadmap+some_notes.pdf
    /tmp/3quantify_2013_10_01_08_ossbtmf_roadmap-what.pdf    
    """
    def __init__(self, name, pattern=_OSSBTMFROADMAPPDF_PATTERN, show_warnings=False):
        super(OssBtmfRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings) # pattern is specialized for this class
        self.timestr = self._get_timestr()
        self.datetime = self._get_datetime()
        self.sensor = self._get_sensor()
        self.system = self._get_system()
        self.sample_rate = self._get_sample_rate()
        self.cutoff = self._get_cutoff()
        self.location = self._get_location()

        # Get command object for "jamming" PDF up/left via offset/scale
        self.pdfjam_cmd = self._get_pdfjam_cmd()
        self.pdfjam_cmdstr = str(self.pdfjam_cmd)
    
    def get_odt_renderer(self):
        pth, fname = os.path.split(self.name)
        bname, ext = os.path.splitext(fname)
        self.odt_name = os.path.join(pth, 'build', bname + '.odt')
        # Explicitly assign page_dict that contains expected names for appy/pod template substitution
        page_dict = self.__dict__
        return Renderer( _HANDBOOK_TEMPLATE_ODT, page_dict, self.odt_name )
    
    def _get_pdfjam_cmd(self):
        xoffset, yoffset = -4.75, 1.0
        scale = 0.88
        orient = 'landscape'
        return HandbookPdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient)
    
    def _get_timestr(self): return self._match.group('timestr')

    def _get_datetime(self): return underscore_as_datetime(self.timestr)

    def _get_sensor(self):
        tmp = self._match.group('sensor')
        sensor, suffix = sensor_tuple(tmp)
        return sensor

    def _get_plot_type(self): return _PLOTTYPES['gvt']

    def _get_system(self): return 'DBQSYS' # FIXME DBQ

    def _get_sample_rate(self): return 0.0625 # FIXME DBQ

    def _get_cutoff(self): return 0.01 # FIXME DBQ
    
    def _get_location(self): return 'DBQLOC' # FIXME DBQ

class SpgxRoadmapPdf(OssBtmfRoadmapPdf):
    """
    Spectrogram Roadmap PDF handbook file like "/tmp/1qualify_2013_10_01_16_00_00.000_121f02ten_spgs_roadmaps500.pdf"
    """
    def __init__(self, name, pattern=_SPGXROADMAPPDF_PATTERN, show_warnings=False):
        super(SpgxRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings)
        self.axis = self._get_axis()
        
    def _get_pdfjam_cmd(self):
        xoffset, yoffset = -3, 1.0
        scale = 0.72
        orient = 'landscape'
        return HandbookPdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient)
   
    def _get_plot_type(self): return _PLOTTYPES['spg']

    def _get_system(self): return 'DBQSYS' # FIXME DBQ

    def _get_sample_rate(self): return 0 # FIXME DBQ

    def _get_cutoff(self): return 0 # FIXME DBQ
    
    def _get_axis(self): return self._match.group('axis')

class IntStatPdf(SpgxRoadmapPdf):
    """
    Interval stat PDF handbook file like "/tmp/2qualify_2013_09_01_121f05006_irmsx_entire_month.pdf"
    """
    def __init__(self, name, pattern=_ISTATPDF_PATTERN, show_warnings=False):
        super(IntStatPdf, self).__init__(name, pattern, show_warnings=show_warnings)
        self.axis = self._get_axis()
        
    def _get_pdfjam_cmd(self):
        xoffset, yoffset = -2, 1.5
        scale = 0.74
        orient = 'landscape'
        return HandbookPdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient)
   
    def _get_plot_type(self): return _PLOTTYPES['istat']

class HandbookPdfjamCommand(PdfjamCommand):

    def __init__(self, *args, **kwargs):
        kwargs['log'] = HandbookLog()
        self.subdir = 'build'
        super(HandbookPdfjamCommand, self).__init__(*args, **kwargs)
        
    def get_outfile(self):
        tmp = super(HandbookPdfjamCommand, self).get_outfile()
        pth, fn = os.path.split(tmp)
        return os.path.join(pth, self.subdir, fn)

# FIXME this class was done without much error trapping and quickly, so...
class HandbookPdftkCommand(PdftkCommand):
    """A better way to get pdftk outfile for handbook ODTs."""
    def __init__(self, odtfile):
        
        if self._verify_fname_ext(odtfile, 'odt'):
            self.odtfile = odtfile
            infile = odtfile.replace('.odt','.pdf')
            if os.path.exists(infile):
                raise RuntimeError('outfile %s already exits' % infile)
        else:
            raise ValueError('odtfile must exist and have odt extension')
        
        ret_code = convert_odt2pdf(odtfile)
        if ret_code: # zero is good return by linux cmd line convention
            raise RuntimeError('did not get zero return from unoconv on %s' % odtfile)
    
        bgfile = self._get_bgfile()
        outfile = infile.replace('.pdf', '_pdftk.pdf')
        super(HandbookPdftkCommand, self).__init__(infile, bgfile, outfile)

    def _get_bgfile(self):
        pth = os.path.dirname(self.odtfile)
        bname = os.path.basename(self.odtfile)
        fpattern = bname.replace('.odt', '_offset_.*_scale_.*\.pdf$')
        files = listdir_filename_pattern(pth, fpattern)
        if len(files) == 1:
            return files[0]
        else:
            return None

class HandbookEntry(object):

    # FIXME is there way to generate this dynamically from classes in this module that end in "Pdf"?
    _FILETYPES = [ OssBtmfRoadmapPdf, SpgxRoadmapPdf, IntStatPdf, HandbookPdf ]

    def __init__( self, source_dir, log=HandbookLog() ):

        # Get info from source_dir
        self.source_dir = source_dir
        self.log = log
        self._parse_source_dir_string() # regime, category, title

    def __str__(self):
        return "\n".join( [self.title, self.category, self.regime] )

    def _parse_source_dir_string(self):
        """ Parse source directory string into fields. """
        parentDir, s = os.path.split(self.source_dir)
        tup = s.split('_')
        regime = _ABBREVS[tup[1]]
        category = title_case_special(tup[2])
        title = ' '.join(tup[3:])
        self.regime, self.category, self.title = regime, category, title
        self.log.process.info( 'Parsed source_dir string: regime:{0}, category:{1}, and title:{2}'.format(regime, category, title) )

    def graceful_mkdir_build(self):
        builddir = os.path.join(self.source_dir, 'build')
        if os.path.isdir(builddir):
            time_stamp = datetime.datetime.now().strftime('%Y_%m_%d_%H_%M_%S')
            newdir = builddir + '_' + time_stamp
            shutil.move(builddir, newdir)
        os.mkdir(builddir)

    def _get_files(self, pth, fname_pattern):
        """Get files that match pattern in pth."""
        files = listdir_filename_pattern(pth, fname_pattern)        
        files.sort()
        return files

    def _get_handbook_files(self):
        """Get files that match pattern for handbook PDFs."""
        fname_pattern = _HANDBOOKPDF_PATTERN[3:] # get rid of ".*/"     # FIXME with low priority
        return self._get_files(self.source_dir, fname_pattern)

    def process_pages(self):
        """Process the files found in source_dir."""
        self.pdf_files = self._get_handbook_files()        
        self.log.process.info( 'Attempting to process %d pages from files in %s' % ( len(self.pdf_files), self.source_dir ) )
        self.graceful_mkdir_build()
        for f in self.pdf_files:
            try:
                
                hbf = guess_file(f, filetypes=self._FILETYPES, show_warnings=False)

                # Add 3 high-level hb entry props to hb file object
                hbf.regime = self.regime
                hbf.category = self.category
                hbf.title = self.title
                
                # Run pdfjam command if this hbf has one                
                if hasattr(hbf, 'pdfjam_cmd'):
                    self.log.process.info(hbf.pdfjam_cmdstr)
                    hbf.pdfjam_cmd.run(log=self.log.process)
                    flag = '^'
                else:
                    flag = 'v'

                # Get ODT renderer and run it to write to-be-editted (imageless) background odt file
                if hasattr(hbf, 'get_odt_renderer'):
                    odt_renderer = hbf.get_odt_renderer()
                    self.log.process.info('Run odt_renderer for hb file %s' % hbf.name)
                    odt_renderer.run()
                    flag += '^'
                else:
                    flag += 'v'                
                
                self.log.process.info( ' '.join( [flag, os.path.basename(f)] ) )
            
            except UnrecognizedPimsFile:
                self.log.process.warn( 'SKIPPED unrecognized file' % f)

    def _get_odt_files(self):
        """Get files that match pattern for ODTs."""
        fname_pattern = _HANDBOOKPDF_PATTERN[3:].replace('.pdf', '.odt') # FIXME with low priority (SEE _get_handbook_files)
        return self._get_files(self.build_dir, fname_pattern)

    def process_build(self):
        """Process the build subdir."""
        self.build_dir = os.path.join(self.source_dir, 'build')
        if os.path.isdir(self.build_dir):
            self.log.process.info( 'Attempting to process build subdir %s' % self.build_dir)
            self.odt_files = self._get_odt_files()        
            for odtfile in self.odt_files:
                pdftk_cmd = HandbookPdftkCommand(odtfile)
                pdftk_cmd.run() 
        else:
            self.log.process.error( 'NOT os.path.isdir for build subdir %s?' % self.build_dir )
        self.finalize_entry()
            
    def finalize_entry(self):
        fname_pattern = _HANDBOOKPDF_PATTERN[3:].replace('.pdf', '_pdftk.pdf') # FIXME can this be better? yeah, right
        infiles = self._get_files(self.build_dir, fname_pattern)
        outfile = os.path.join(self.source_dir, 'hb_OUTFILE.pdf')
        pdfjoin_cmd = PdfjoinCommand(infiles, outfile)
        pdfjoin_cmd.run()

if __name__ == '__main__':
    #hbe = HandbookEntry(source_dir='/home/pims/Documents/test/hb_vib_vehicle_Big_Bang')
    hbe = HandbookEntry(source_dir='/misc/yoda/www/plots/user/handbook/source_docs/hb_vib_vehicle_EWIS_Port_Truss_Unknown')
    hbe.process_pages()
    #hbe.process_build() 
    pass
