"""
Utilities for handling handbook files.
"""
import re
from pims.core.files.base import RecognizedFile

def guess_file(name):
    """
    Attempt to guess file based on name.
    """
    filetypes = [ HandbookFile, RoadmapPdfFile ]
    for i in filetypes:
        try:
            p = i(name, showWarnings=False)
            return p
        except UnrecognizedFile:
            pass
    if showWarnings:
        print 'Unrecognized file "%s"' % name
    return UnrecognizedFile(name)

class HandbookFile(RecognizedFile):
    """
    A mixin for use alongside pims.core.files.base.RecognizedFile, which provides
    additional features for dealing with handbook files.
    """
    def __init__(self, name, pattern='.*(\d{1})(qualify|quantify|ancillary)_.*\.pdf$', show_warnings=False):
        self.pattern = pattern
        super(HandbookFile, self).__init__(name, show_warnings=show_warnings)

    def __str__(self):
        s = []
        s.append( '%s object for recognized PIMS file "%s" because %s' % (self.__class__.__name__, self.name, self.why() ))
        for key in self.__dict__:
            s.append("{key}='{value}'".format(key=key, value=self.__dict__[key]))
        return '\n'.join(s)        

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

    def is_recognized(self):
        if not self._get_match():
            self._recognized = False
        else:
            self._recognized = True
            self._type = self.type()
        return self._recognized

    def _get_match(self):
        self._match = re.search(self.pattern, self.name)
        return self._match
    
    def _get_offset(self):
        return '-4.25cm 1cm'
    offset = property(_get_offset)

    def _get_scale(self):
        return '0.88'
    scale = property(_get_scale)

    def _get_page(self):
        return self._match.group(1)
    page = property(_get_page) # similar for self.pdfjamOffset = '-4.25cm 1cm'?

    def _get_subtitle(self):
        return self._match.group(2)
    subtitle = property(_get_subtitle) # self.pdfjamScale = '0.88'?

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
    OSSBTMF Roadmap PDF handbook file like "/tmp/2quantify_2013_10_01_08_ossbtmf_roadmap.pdf"
    """
    def __init__(self, name, pattern='.*(\d{1})(qualify|quantify)_(.*)_(ossbtmf)_roadmap\+*(.*)\.pdf$', show_warnings=False):
        self.pattern = pattern
        super(RecognizedFile, self).__init__(name, show_warnings=show_warnings) # NOTE: we want super of recognized file init here
        self._recognized = None
        self._type = None
        self._why = None
        if not self.is_recognized(): raise UnrecognizedPimsFile('"%s"' % self.name)

    def __str__(self):
        return str( self.asDict() )

    def _get_offset(self):
        return '-3.75cm 0.99cm'

    def _get_scale(self):
        return '0.92'

    def _get_timestr(self):
        return self._match.group(3)
    timestr = property(_get_timestr)

    def _get_sensor(self):
        return self._match.group(4)
    sensor = property(_get_sensor)

    def _get_notes(self):
        return self._match.group(5)
    notes = property(_get_notes)

    def type(self):
        if not self._type:
            self._type = 'hb_ossbmtf_roadmap_pdf'
        return self._type

    def asDict(self):
        myDict = super(OssBtmfRoadmapPdf, self).asDict()
        myDict['system'] = 'MAMS'
        #myDict['sensor'] = self.sensor
        myDict['sampleRate'] = 0.0625
        myDict['cutoff'] = 0.01
        myDict['plotType'] = 'gvt3'
        myDict['location'] = 'LAB1O2, ER1, Lockers 3,4' # FIXME if MAMS OSS ever moves
        myDict['timestr'] = self.timestr
        myDict['notes'] = self.notes
        return myDict
