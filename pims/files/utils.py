import os
import re
from pims.files.base import File, UnrecognizedPimsFile
from pims.patterns.handbookpdfs import is_unique_handbook_pdf_match
from pims.patterns.dailyproducts import _BATCHROADMAPS_PATTERN
from pims.utils.pimsdateutil import timestr_to_datetime

def parse_roadmap_filename(f):
    """Parse roadmap filename."""
    m = re.match(_BATCHROADMAPS_PATTERN, f)
    if m:
        dtm = timestr_to_datetime(m.group('dtm'))
        sensor = m.group('sensor')
        abbrev = m.group('abbrev')
        return dtm, sensor, abbrev, os.path.basename(f)
    else:
        return 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', "%s" % os.path.basename(f)

def guess_file(name, file_type_classes, show_warnings=False):
    """
    Verify unique pattern, then guess class based on its name.
    """
    p = File(name)
    p.recognized = False
    if is_unique_handbook_pdf_match(name):
        for i in file_type_classes:
            try:
                p = i(name, show_warnings=show_warnings)
                return p
            except UnrecognizedPimsFile:
                pass
    if show_warnings and not p.recognized:
        print 'Unrecognized file "%s"' % name
    return p

def listdir_filename_pattern(dirpath, fname_pattern):
    """Listdir files that match fname_pattern."""
    if not os.path.exists(dirpath):
        return None
    files = [os.path.join(dirpath, f) for f in os.listdir(dirpath) if re.match(fname_pattern, f)]
    files.sort()
    return files

def filter_filenames(dirpath, predicate):
    """Usage:
           >>> filePattern = '\d{14}.\d{14}/\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}.\d{3}.\d{4}_\d{2}_\d{2}_\d{2}_\d{2}_\d{2}.\d{3}.*'
           >>> dirpath = '/misc/jaxa'
           >>> predicate = re.compile(r'/misc/jaxa/' + filePattern).match
           >>> for filename in filter_filenames(dirpath, predicate):
           ....    # do something
    """
    for root, dirnames, filenames in os.walk(dirpath):
        for filename in filenames:
            abspath = os.path.join(root, filename)
            if predicate(abspath):
                yield abspath
                