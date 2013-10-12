"""
Utilities for handling handbook files.
"""
import re
from pims.core.files.base import RecognizedFile, UnrecognizedPimsFile
from pims.core.strings.utils import underscore_as_datetime
from pims.patterns.handbookpdfs import *

# TODO aggregate all the regexp patterns into neat, easy to update way
# TODO some properties can be queried from [yoda?] db with time and sensor designation, right?

class HandbookPdf(RecognizedFile):
    """
    A mixin for use alongside pims.core.files.base.RecognizedFile, which provides
    additional features for dealing with handbook files.
    """ # WHY CAN WE USE RE OBJ FOR PATTERN INPUT AND NOT NEED ".pattern" FOR A STRING???
    def __init__(self, name, pattern=_HANDBOOKPDF_FORMAT, show_warnings=False):
        super(HandbookPdf, self).__init__(name, pattern, show_warnings=show_warnings)

    def __str__(self):
        s = '%s isa %s\n' % (self.name, self.__class__.__name__)
        D = [ (x, self.asDict()[x]) for x in self.asDict()] # convert to tuple
        alpha = sorted(D, key = lambda x: x[0]) # alpha sort on keys
        s += '\n'.join(elem[0]+':'+str(elem[1]) for elem in alpha)        
        return s

    def __repr__(self):
        return self.__str__()
        
    def showdict(self):
        s = []
        s.append( '%s object for recognized PIMS file "%s" because %s' % (self.__class__.__name__, self.name, self.why() ))
        for key in self.__dict__:
            s.append("{key}='{value}'".format(key=key, value=self.__dict__[key]))
        print '\n'.join(s)             

    def _get_match(self): return re.search(self.pattern, self.name)
    _match = property(_get_match)

    def is_recognized(self):
        self.recognized = False
        if self._match:
            self.recognized = True
        return self.recognized
   
    def _get_offset(self): return '0cm 0cm'
    offset = property(_get_offset)

    def _get_scale(self): return '1.00'
    scale = property(_get_scale)

    def _get_page(self): return self._match.group('page')
    page = property(_get_page)

    def _get_subtitle(self): return self._match.group('subtitle')
    subtitle = property(_get_subtitle)

    def _get_notes(self): return self._match.group('notes') or 'empty'
    notes = property(_get_notes)

    def asDict(self):
        myDict = super(HandbookPdf, self).asDict()
        myDict['notes'] = self.notes
        myDict['page'] = self.page
        myDict['subtitle'] = self.subtitle
        myDict['offset'] = self.offset
        myDict['scale'] = self.scale
        return myDict

class OssBtmfRoadmapPdf(HandbookPdf):
    """
    OSSBTMF Roadmap PDF handbook file like one of these examples:
    /tmp/1qualify_2013_10_01_08_ossbtmf_roadmap.pdf
    /tmp/2quantify_2013_10_01_08_ossbtmf_roadmap+some_notes.pdf
    /tmp/3quantify_2013_10_01_08_ossbtmf_roadmap-what.pdf    
    """
    def __init__(self, name, pattern=_OSSBTMFROADMAPPDF_FORMAT, show_warnings=False):
        super(OssBtmfRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings) # pattern is specialized for this class

    def _get_offset(self): return '-4.25cm 1cm'
    offset = property(_get_offset)

    def _get_scale(self): return '0.88'
    scale = property(_get_scale)

    def _get_timestr(self): return self._match.group('timestr')
    timestr = property(_get_timestr)

    def _get_datetime(self): return underscore_as_datetime(self.timestr)
    datetime = property(_get_datetime)

    def _get_sensor(self): return self._match.group('sensor')
    sensor = property(_get_sensor)

    def asDict(self):
        # establish page, subtitle, offset, and scale
        myDict = super(OssBtmfRoadmapPdf, self).asDict()
        myDict['system'] = 'MAMS'
        myDict['sensor'] = self.sensor
        myDict['sampleRate'] = 0.0625
        myDict['cutoff'] = 0.01
        myDict['plotType'] = 'gvt3'
        myDict['location'] = 'LAB1O2, ER1, Lockers 3,4' # FIXME if MAMS OSS ever moves
        myDict['datetime'] = self.datetime
        myDict['notes'] = self.notes
        return myDict

class SpgxRoadmapPdf(OssBtmfRoadmapPdf):
    """
    Spectrogram Roadmap PDF handbook file like "/tmp/1qualify_2013_10_01_16_00_00.000_121f02ten_spgs_roadmaps500.pdf"
    """
    def __init__(self, name, pattern=_SPGXROADMAPPDF_FORMAT, show_warnings=False):
        super(OssBtmfRoadmapPdf, self).__init__(name, pattern, show_warnings=show_warnings) # NOTE: we want super of recognized file init here

    def _get_axis(self): return self._match.group('axis')
    axis = property(_get_axis)
    
    def _get_sensor(self): return self._match.group('sensor') + '<< PARSE FURTHER?'
    sensor = property(_get_sensor)

    def asDict(self):
        # establish page, subtitle, offset, and scale
        myDict = super(OssBtmfRoadmapPdf, self).asDict()
        myDict['system'] = 'LUT4SYS'
        myDict['sensor'] = self.sensor
        myDict['sampleRate'] = 0
        myDict['plotType'] = 'spg'
        myDict['location'] = 'LUT4LOC'
        myDict['axis'] = self.axis
        myDict['datetime'] = self.datetime
        myDict['notes'] = self.notes
        return myDict
    