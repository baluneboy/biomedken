from pims.core.files.base import File, UnrecognizedPimsFile

def guess_file(name, filetypes, show_warnings=False):
    """
    Attempt to guess file based on its name.
    """
    # Keep more general types at end of filetypes list
    for i in filetypes:
        try:
            p = i(name, show_warnings=show_warnings)
            return p
        except UnrecognizedPimsFile:
            pass
    if show_warnings:
        print 'Unrecognized file "%s"' % name
    p = File(name)
    p.recognized = False
    return p
