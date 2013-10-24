import os
import re
from pims.files.base import File, UnrecognizedPimsFile
from pims.patterns.handbookpdfs import is_unique_handbook_pdf_match

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
    files = [os.path.join(dirpath, f) for f in os.listdir(dirpath) if re.match(fname_pattern, f)]
    files.sort()
    return files
