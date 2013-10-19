#!/usr/bin/env python
"""
Utilities for building handbook files.
"""
import inspect
import os
import sys
import re
import datetime
from pims.files.base import RecognizedFile, UnrecognizedPimsFile
from pims.strings.utils import underscore_as_datetime, title_case_special, sensor_tuple
from pims.files.utils import guess_file
from pims.patterns.handbookpdfs import * # THIS IS WHERE PATTERNS ARE DEFINED/REFINED
from pims.files.utils import listdir_filename_pattern
from pims.files.pdfs.pdfjam import PdfjamCommand, PdfjoinCommand
from pims.files.log import HandbookLog
from pims.files.pod.templates import _HANDBOOK_TEMPLATE_ODT, _HANDBOOK_TEMPLATE_ANCILLARY_ODT
from pims.files.pdfs.pdftk import PdftkCommand, convert_odt2pdf
from pims.pad.padheader import PadHeaderDict
from appy.pod.renderer import Renderer
from pims.paths import _YODA_HANDBOOK_DIR
from pims.database.pimsquery import db_insert_handbook

# TODO see /home/pims/dev/programs/python/pims/README.txt

class HandbookPdf(RecognizedFile):
    """
    A class derived from RecognizedFile, which provides
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
    OSSBTMF Roadmap PDF handbook file like this example:
    /tmp/2quantify_2013_10_01_08_ossbtmf_roadmap+some_notes.pdf
    """
    def __init__(self, name, pattern=_OSSBTMFROADMAPPDF_PATTERN, show_warnings=False):
        super(OssBtmfRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings) # pattern is specialized for this class
        self.timestr = self._get_timestr()
        self.datetime = self._get_datetime()
        self.sensor = self._get_sensor()
        self.pad_header = PadHeaderDict(self.sensor, self.datetime)
        
        # Get header type info
        self.system = self.pad_header['System']
        self.sample_rate = self.pad_header['SampleRate']
        self.cutoff = self.pad_header['CutoffFreq']
        self.location = self.pad_header['Location']

        # Get command object for pdfjam -> slightly shrunk PDF up/left via offset/scale
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
        xoffset, yoffset = -4.25, 1.0
        scale = 0.86
        orient = 'landscape'
        return HandbookPdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient)
    
    def _get_timestr(self): return self._match.group('timestr')

    def _get_datetime(self): return underscore_as_datetime(self.timestr)

    def _get_sensor(self):
        tmp = self._match.group('sensor')
        sensor, suffix = sensor_tuple(tmp)
        # FIXME a better regex pattern would probably help here:
        if suffix and ( suffix.endswith('006') or suffix.endswith('one') ):
            return sensor + '006'
        else:
            return sensor

    def _get_plot_type(self): return _PLOTTYPES['gvt']

class SpgxRoadmapPdf(OssBtmfRoadmapPdf):
    """
    Spectrogram Roadmap PDF handbook file like this example:
    /tmp/1qualify_2013_10_01_16_00_00.000_121f02ten_spgs_roadmaps500_maybe_notes.pdf
    """
    def __init__(self, name, pattern=_SPGXROADMAPPDF_PATTERN, show_warnings=False):
        super(SpgxRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings)
        self.axis = self._get_axis()
    
    # FIXME if sensor suffix is "one", then scale a bit smaller to maybe 0.83?
    def _get_pdfjam_cmd(self):
        xoffset, yoffset = -4.25, 1.0
        scale = 0.86
        orient = 'landscape'
        return HandbookPdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient)
   
    def _get_plot_type(self): return _PLOTTYPES['spg']
    
    def _get_axis(self): return self._match.group('axis')

class Psd3RoadmapPdf(SpgxRoadmapPdf):
    """
    PSD XYZ PDF handbook file like this example:
    /tmp/4qualify_2013_10_08_13_35_00_es03_psd3_compare_msg_wv3fans.pdf
    """
    def __init__(self, name, pattern=_PSD3ROADMAPPDF_PATTERN, show_warnings=False):
        super(Psd3RoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings)

    def _get_plot_type(self): return _PLOTTYPES['psd']

class CvfsRoadmapPdf(SpgxRoadmapPdf):
    """
    Cumulative RMS vs. frequency (sum) PDF handbook file like this example:
    /tmp/5quantify_2013_10_08_13_35_00_es03_cvfs_msg_wv3fans_compare.pdf
    """
    def __init__(self, name, pattern=_CVFSROADMAPPDF_PATTERN, show_warnings=False):
        super(CvfsRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings)

    def _get_plot_type(self): return _PLOTTYPES['cvf']

    def _get_pdfjam_cmd(self):
        xoffset, yoffset = -4.25, 1.0
        scale = 0.82
        orient = 'landscape'
        return HandbookPdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient)

class IntStatPdf(SpgxRoadmapPdf):
    """
    Interval stat PDF handbook file like this example:
    /tmp/2qualify_2013_09_01_121f05006_irmsx_entire_month.pdf
    """
    def __init__(self, name, pattern=_ISTATPDF_PATTERN, show_warnings=False):
        super(IntStatPdf, self).__init__(name, pattern, show_warnings=show_warnings)
        self.axis = self._get_axis()
        
    def _get_pdfjam_cmd(self):
        xoffset, yoffset = -4.25, 1.0
        scale = 0.86
        orient = 'landscape'
        return HandbookPdfjamCommand(self.name, xoffset=xoffset, yoffset=yoffset, scale=scale, orient=orient)
   
    def _get_plot_type(self): return _PLOTTYPES['istat']

# FIXME do some log.info
class HandbookPdfjamCommand(PdfjamCommand):
    """A custom pdfjam command handler."""
    def __init__(self, *args, **kwargs):
        kwargs['log'] = HandbookLog()
        self.subdir = 'build'
        super(HandbookPdfjamCommand, self).__init__(*args, **kwargs)
        
    def get_outfile(self):
        tmp = super(HandbookPdfjamCommand, self).get_outfile()
        pth, fn = os.path.split(tmp)
        return os.path.join(pth, self.subdir, fn)

# FIXME do some log.info
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
    """
    A handbook entry container that processes recognized pdf files in a recognized
    source_dir to create editable ODTs as interim products, then can build from those
    the end item, which gets inserted into db on yoda.
    """
    def __init__( self, source_dir, log=HandbookLog() ):
        # Get info from source_dir
        self.source_dir = source_dir
        self.log = log
        pth, dname = os.path.split(source_dir)
        self._fname = dname + '.pdf'
        self.hb_pdf = os.path.join(source_dir, self._fname)
        self.regime, self.category, self.title = self._parse_source_dir_string()
        self._pdf_classes = self._get_class_members()

    def __str__(self):
        return "\n".join( [self.title, self.category, self.regime] )

    def will_clobber(self):
        """Return True if we are gonna clobber existing file on yoda."""
        # check if clobber existing hb pdf at destination on yoda
        if os.path.exists( os.path.join(_YODA_HANDBOOK_DIR, self._fname) ):
            return True
        else:
            return False

    def _get_class_members(self):
        _class_members = []
        clsmembers = inspect.getmembers(sys.modules[__name__], inspect.isclass)
        for cls_name, cls in clsmembers:
            if cls_name.endswith('Pdf') and not cls_name.startswith('Handbook'):
                _class_members.append(cls)
        return _class_members

    def _parse_source_dir_string(self):
        """ Parse source directory string into regime, category, and title. """
        parentDir, s = os.path.split(self.source_dir)
        tup = s.split('_')
        regime = _ABBREVS[tup[1]]
        category = title_case_special(tup[2])
        title = ' '.join(tup[3:])
        self.log.process.info( 'Parsed source_dir string: regime:{0}, category:{1}, and title:{2}'.format(regime, category, title) )
        return regime, category, title

    def graceful_mkdir_build(self):
        """Rename if pre-existing build subdir and make a fresh build subdir."""
        builddir = os.path.join(self.source_dir, 'build')
        if os.path.isdir(builddir):
            time_stamp = datetime.datetime.now().strftime('%Y_%m_%d_%H_%M_%S')
            newdir = builddir + '_' + time_stamp
            os.rename(builddir, newdir)
        os.mkdir(builddir)

    def _get_files(self, pth, fname_pattern):
        """Get files that match filename pattern at path."""
        return listdir_filename_pattern(pth, fname_pattern)        

    def _get_handbook_files(self):
        """Get files that match pattern for handbook PDFs."""
        fname_pattern = _HANDBOOKPDF_PATTERN[3:] # get rid of ".*/"
        return self._get_files(self.source_dir, fname_pattern)

    def process_pages(self):
        """Process the files found in source_dir."""
        self.pdf_files = self._get_handbook_files()        
        self.log.process.info( 'Attempting to process %d pages from files in %s' % ( len(self.pdf_files), self.source_dir ) )
        self.graceful_mkdir_build()
        for f in self.pdf_files:
            try:
                
                hbf = guess_file(f, filetypes=self._pdf_classes, show_warnings=False)

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
                self.log.process.warn( 'SKIPPED unrecognized file %s' % f)
        
        self.ancillary_odt_renderer = self.get_ancillary_odt_renderer()
        self.ancillary_odt_renderer.run()

    def get_ancillary_odt_name(self):
        """Create ancillary odt filename."""
        fname = 'ancillary_notes.odt'
        return os.path.join(self.source_dir, 'build', fname)

    def get_ancillary_odt_renderer(self):
        """After processing pages, create ancillary odt as last page."""
        ancillary_odt_name = self.get_ancillary_odt_name()
        # Explicitly assign page_dict that contains expected names for appy/pod template substitution
        ancillary_dict = {'title': self.title}
        return Renderer( _HANDBOOK_TEMPLATE_ANCILLARY_ODT, ancillary_dict, ancillary_odt_name )        

    def _get_odt_files(self):
        """Get files that match pattern for ODTs."""
        fname_pattern = _HANDBOOKPDF_PATTERN[3:].replace('.pdf', '.odt') # FIXME with low priority (SEE _get_handbook_files)
        return self._get_files(self.build_dir, fname_pattern)

    def process_build(self):
        """Process files (pages) in the build subdir."""
        self.build_dir = os.path.join(self.source_dir, 'build')
        if os.path.isdir(self.build_dir):
            self.log.process.info( 'Attempting process_build in %s' % self.build_dir)
            self.odt_files = self._get_odt_files()        
            for odtfile in self.odt_files:
                pdftk_cmd = HandbookPdftkCommand(odtfile)
                pdftk_cmd.run()
            self.log.process.info('Ran pdftk_cmd for %d odt files' % len(self.odt_files))
        else:
            self.log.process.error( 'NOT os.path.isdir for build subdir %s?' % self.build_dir )
        
        # get list of files to join (except for ancillary at this point)
        fname_pattern = _HANDBOOKPDF_PATTERN[3:].replace('.pdf', '_pdftk.pdf')
        self.unjoined_files = self._get_files(self.build_dir, fname_pattern)
        
        # convert ancillary ODT to PDF, prepend page num, and include with other pages to be joined
        ancillary_pdf = self.convert_ancillary( len(self.unjoined_files)+1 )
        self.unjoined_files.append(ancillary_pdf)
        self.log.process.info('We now have %d unjoined files, including ancillary file' % len(self.unjoined_files))
        
        # finalize
        if self.finalize_entry():
            self.log.process.info('Okay, finalized entry')
        else:
            self.log.process.error('Could NOT finalize_entry for some reason')
    
    def finalize_entry(self):
        """Rename a pre-existing hb pdf, then create final hb pdf for db and web."""
        self.log.process.info('Attempting to finalize_entry')
        if os.path.exists(self.hb_pdf):
            time_stamp = datetime.datetime.now().strftime('%Y_%m_%d_%H_%M_%S')
            os.rename(self.hb_pdf, self.hb_pdf + '.' + time_stamp)
            self.log.process.info('Renamed hb_pdf with time stamp')
        pdfjoin_cmd = PdfjoinCommand(self.unjoined_files, self.hb_pdf)
        pdfjoin_cmd.run()
        self.log.process.info('Ran pdfjoin command to get %s' % self.hb_pdf)
        if os.path.exists(self.hb_pdf):
            unused_flag, err_msg = self.unbuild(execute=True)
            if err_msg:
                self.log.process.error('SKIP db_insert because unbuild error msg: %s' % err_msg)
                return False
            else:
                self.log.process.info('Did the unbuild okay')
            self.db_insert()
        else:
            self.log.process.info('Did NOT unbuild because hb_pdf did not exist')
        return True

    # TODO needs work for details and PROBABLY a new stored procedure on yoda?
    def db_insert(self):
        """Insert db record via Eric's routine on yoda."""
        fname = os.path.basename(self.hb_pdf)
        inserted_okay, msg =  db_insert_handbook(fname, self.title, 'vibratory', None)
        if inserted_okay:
            self.log.process.info(msg)
        else:
            self.log.process.error(msg)

    # FIXME do some log.info here for files getting tossed (or not matching ODT), etc.
    def unbuild(self, execute=True):
        """
        Check if we are ready to unbuild, which allows for modified ODTs.
        *if execute is True, then actually do the rebuild
        """
        files_to_toss = []
        
        # Remove *_pdftk.pdf files
        build_dir = os.path.join(self.source_dir, 'build')
        pdftk_files = self._get_files(build_dir, '.*_pdftk.pdf')
        if not pdftk_files:
            msg = 'NO pdftk_pdf files found during unbuild'
            return False, msg
        files_to_toss += pdftk_files

        # Remove *.pdf files that have matching .odt file
        pdf_files_matching_odt = []
        odt_files = self._get_files(build_dir, '.*.odt')
        for odt_file in odt_files:
            pdf_file = odt_file.replace('.odt', '.pdf')
            if os.path.exists(pdf_file):
                pdf_files_matching_odt.append(pdf_file)
            else:
                msg = 'Seems unpaired odt/pdf files'
                return False, msg
        files_to_toss += pdf_files_matching_odt

        # Get '\dancillary_.*\.odt'
        dancillary_odt = self._get_files(build_dir, '\dancillary_.*.odt')
        if len(dancillary_odt) == 1:
            dancillary_odt = dancillary_odt[0]
        else:
            msg = 'NO unbuild because len(dancillary_odt) not exactly one'
            return False, msg
        
        # Rename \dancillary_.*\.odt WITHOUT leading page num digit
        pth, bname = os.path.split(dancillary_odt)
        renamed_odt = os.path.join(pth, bname[1:])
        try:
            os.rename( dancillary_odt, renamed_odt )
            os.rename( renamed_odt, dancillary_odt )
        except:
            msg = 'Could not rename dancillary odt file to no-leading-digit odt file'
            return False, msg

        # Get out here if okay to unbuild, but not wanting to execute
        if not execute:
            msg = 'Okay to unbuild, but execute boolean input is False, so skip out'
            return True, msg
        
        # Actually do the unbuild
        [os.remove(f) for f in files_to_toss]
        os.rename( dancillary_odt, renamed_odt )
        return False, None
    
    def convert_ancillary(self, page_num):
        """Use unoconv for ancillary odt with prepend of page number."""
        self.ancillary_odt_name = self.get_ancillary_odt_name()
        new_name = self.ancillary_odt_name.replace('ancillary_', '%dancillary_' % page_num)
        os.rename(self.ancillary_odt_name, new_name)
        ret_code = convert_odt2pdf(new_name)
        return new_name.replace('.odt','.pdf')


if __name__ == '__main__':
    
    hbe = HandbookEntry(source_dir='/home/pims/Documents/test/hb_vib_vehicle_Big_Bang')
    
    #hbe = HandbookEntry(source_dir='/misc/yoda/www/plots/user/handbook/source_docs/hb_vib_equipment_MSG_Operations')
    #hbe = HandbookEntry(source_dir='/misc/yoda/www/plots/user/handbook/source_docs/hb_qs_equipment_Robonaut_Goes_Off')
    
    #hbe.dbInsert("It's A Miracle", self.regime, 'vehicle', author='Ken Hrovat', host='localhost', user='pims', passwd='PIMSPASS', db='pimsdoc')
    #raise SystemExit
    
    if False: # False for process_build
        
        if not hbe.will_clobber():
            hbe.process_pages()
        else:
            print 'ABORT PAGE PROCESSING: hb pdf filename conflict on yoda'
    
    else:
        
        if not hbe.will_clobber():
            hbe.process_build()
        else:
            print 'ABORT BUILD: hb pdf filename conflict on yoda'
    
    #ok_to_unbuild, msg = hbe.unbuild(execute=False)
    #print "ok_to_unbuild", ok_to_unbuild
    #print msg
    pass
