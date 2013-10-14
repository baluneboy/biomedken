#!/usr/bin/env python

import os
import pygtk
pygtk.require('2.0')
import gtk
import re
from pims.patterns.dirnames import _HANDBOOKDIR_PATTERN
from pims.core.files.handbook import HandbookEntry

def alert(msg):
    """Show a dialog with a simple message."""
    dialog = gtk.MessageDialog()
    dialog.set_markup(msg)
    dialog.run()

def main():
    # Get nautilus current uri
    curdir = os.environ.get('NAUTILUS_SCRIPT_CURRENT_URI', os.curdir)
    
    # Strip off uri prefix
    if curdir.startswith('file:///'):
        curdir = curdir[7:]
        
    # Verify curdir matches pattern (this works even in build subdir, a good thing)
    match = re.search( re.compile(_HANDBOOKDIR_PATTERN), curdir )
       
    # Do branching
    if match:
        #alert( match.string )
        if match.string.endswith('build'):
            # finalize the product
            hbe = HandbookEntry( source_dir=os.path.dirname(curdir) )
            hbe.process_build()        
            msg = 'did pdftk post-processing'
        else:
            # create interim hb entry build products
            hbe = HandbookEntry( source_dir=curdir )
            hbe.process_pages()     
            msg = 'pre-processed %d hb pdf files' % len(hbe.pdf_files)
    else:
        msg = 'ignore non-hb dir'
        
    alert( '%s' % msg )

if __name__ == "__main__":
    main()
