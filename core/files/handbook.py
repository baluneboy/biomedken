"""
Utilities for handling handbook files.
"""
import re
from pims.core.files.base import RecognizedFile, UnrecognizedPimsFile

# TODO aggregate all the regexp patterns into neat, easy to update way
# TODO some properties can be queried from [yoda?] db with time and sensor designation, right?

class HandbookFile(RecognizedFile):
    """
    A mixin for use alongside pims.core.files.base.RecognizedFile, which provides
    additional features for dealing with handbook files.
    """
    def __init__(self, name, pattern='.*(?P<page>\d{1})(?P<subtitle>qualify|quantify|ancillary)_.*\.pdf$', show_warnings=False):
        super(HandbookFile, self).__init__(name, pattern, show_warnings=show_warnings)
        self.page = self._get_page()
        self.subtitle = self._get_subtitle()
        self.offset = self._get_offset()
        self.scale = self._get_scale()
        
    def showdict(self):
        s = []
        s.append( '%s object for recognized PIMS file "%s" because %s' % (self.__class__.__name__, self.name, self.why() ))
        for key in self.__dict__:
            s.append("{key}='{value}'".format(key=key, value=self.__dict__[key]))
        print '\n'.join(s)        

    def __repr__(self):
        return self.__str__()

    def why(self):
        if not self._why:
            self._why = 'matches regexp "%s"' % self.pattern
        return self._why

    def type(self):
        if not self._type:
            self._type = 'a_somewhat_recognized_handbook_file'
        return self._type

    def _get_match(self): return re.search(self.pattern, self.name)
    _match = property(_get_match)

    def is_recognized(self):
        if not self._match:
            self.recognized = False
        else:
            self.recognized = True
            self._type = self.type()
        return self.recognized
   
    def _get_offset(self): return '0cm 0cm'

    def _get_scale(self): return '1.00'

    def _get_page(self): return self._match.group('page')

    def _get_subtitle(self): return self._match.group('subtitle')

    def asDict(self):
        myDict = super(HandbookFile, self).asDict()
        myDict['page'] = self.page
        myDict['subtitle'] = self.subtitle
        myDict['offset'] = self.offset
        myDict['scale'] = self.scale
        return myDict

    def patternNotes(self):
        return """
        #===========================================================================
        #
        #yyyy_mm_dd_HH_MM_ss.sss_SENSOR_PLOTTYPE_roadmapsRATE.pdf
        #(DTOBJ, SYSTEM=SMAMS, SENSOR, PLOTTYPE={pcss|spgX}, fs=RATE, fc='unknown', LOCATION='fromdb')
        #------------------------------------------------------------
        #2013_10_01_00_00_00.000_121f02_pcss_roadmaps500.pdf
        #2013_10_01_08_00_00.000_121f05ten_spgx_roadmaps500.pdf
        #2013_10_01_08_00_00.000_121f03one_spgs_roadmaps142.pdf
        #2013_10_01_08_00_00.000_hirap_spgs_roadmaps1000.pdf
        #
        #===========================================================================
        #
        #yyyy_mm_dd_HH_ossbtmf_roadmap.pdf
        #(DTOBJ, SYSTEM=MAMS, SENSOR=OSSBTMF, PLOTTYPE=gvt3, fs=0.0625, fc=0.01, LOCATION=LAB1O2, ER1, Lockers 3,4)
        #------------------------------------------------------------
        #2013_10_01_08_ossbtmf_roadmap.pdf
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        classPatterns = (
            ( OssBtmfRoadmapPdf,    '.*(\d{1})(qualify|quantify).*_ossbtmf_roadmap(\+.*){0,1}\.pdf$' ),                 # .*_ossbtmf_roadmap\.pdf
            ( SpgxRoadmapPdf,       '.*(\d{1})(qualify|quantify)_(.*)_(.*)_(spg.)_roadmaps(.*)(\+.*){0,1}\.pdf$' ),     # .*_ossbtmf_roadmap\.pdf
            ( PcssRoadmapPdf,       '.*(\d{1})(qualify|quantify).*_pcss_roadmaps(.*)(\+.*){0,1}\.pdf$' ),               #   .*_pcss_roadmaps.*\.pdf
            ( AncillaryPdf,         '.*(\d{1})(ancillary).*\.pdf$' ),                                                   #   .*_pcss_roadmaps.*\.pdf
            )
        """

class OssBtmfRoadmapPdf(HandbookFile):
    """
    OSSBTMF Roadmap PDF handbook file like one of these examples:
    /tmp/1qualify_2013_10_01_08_ossbtmf_roadmap.pdf
    /tmp/2quantify_2013_10_01_08_ossbtmf_roadmap+some_notes.pdf
    /tmp/3quantify_2013_10_01_08_ossbtmf_roadmap-what.pdf    
    """
    def __init__(self, name, pattern='.*(?P<page>\d{1})(?P<subtitle>qualify|quantify)_(?P<timestr>.*)_(?P<sensor>ossbtmf)_roadmap(?P<notes>.*)\.pdf$', show_warnings=False):
        super(OssBtmfRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings) # NOTE: we want super of recognized file init here

    def __str__(self):
        return str( self.asDict() )

    def _get_offset(self): return '-4.25cm 1cm'

    def _get_scale(self): return '0.88'

    def _get_timestr(self): return self._match.group('timestr')
    timestr = property(_get_timestr)

    def _get_sensor(self): return self._match.group('sensor')
    sensor = property(_get_sensor)

    def _get_notes(self): return self._match.group('notes')
    notes = property(_get_notes)

    def type(self):
        if not self._type:
            self._type = 'hb_ossbmtf_roadmap_pdf'
        return self._type

    def asDict(self):
        myDict = super(OssBtmfRoadmapPdf, self).asDict()
        myDict['system'] = 'MAMS'
        myDict['sensor'] = self.sensor
        myDict['sampleRate'] = 0.0625
        myDict['cutoff'] = 0.01
        myDict['plotType'] = 'gvt3'
        myDict['location'] = 'LAB1O2, ER1, Lockers 3,4' # FIXME if MAMS OSS ever moves
        myDict['timestr'] = self.timestr
        myDict['notes'] = self.notes
        return myDict

class SpgxRoadmapPdf(OssBtmfRoadmapPdf):
    """
    Spectrogram Roadmap PDF handbook file like "/tmp/1qualify_2013_10_01_16_00_00.000_121f02ten_spgs_roadmaps500.pdf"
    """
    def __init__(self, name, pattern='.*(?P<page>\d{1})(?P<subtitle>qualify|quantify)_(?P<timestr>.*)_(?P<sensor>.*)_spg(?P<axis>.)_roadmaps(?P<sampleRate>[0-9]*[p\.]?[0-9]+)(?P<notes>.*)\.pdf$', show_warnings=False):
        super(OssBtmfRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings) # NOTE: we want super of recognized file init here
