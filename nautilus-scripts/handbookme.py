#!/usr/bin/env python

import os
import pygtk
pygtk.require('2.0')
import gtk
import re
from pims.patterns.dirnames import _HANDBOOKDIR_PATTERN
from pims.files.handbook import HandbookEntry

def alert_dialog(msg, title='ALERT'):
    label = gtk.Label(msg)
    dialog = gtk.Dialog(title,
                       None,
                       gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
                       (gtk.STOCK_CANCEL, gtk.RESPONSE_REJECT,
                        gtk.STOCK_OK, gtk.RESPONSE_ACCEPT))
    dialog.vbox.pack_start(label)
    label.show()
    checkbox = gtk.CheckButton("Useless checkbox")
    dialog.action_area.pack_end(checkbox)
    checkbox.show()
    response = dialog.run()
    dialog.destroy()

#alert_dialog('my details')
#raise SystemExit

def alert(msg):
    """Show a dialog with a simple message."""
    dialog = gtk.MessageDialog()
    dialog.set_markup(msg)
    dialog.run()

def do_build(pth):
    """Create interim hb entry build products."""
    hbe = HandbookEntry( source_dir=pth )
    if not hbe.will_clobber():
        err_msg = hbe.process_pages()     
        return err_msg or 'pre-processed %d hb pdf files' % len(hbe.pdf_files)
    else:
        return 'ABORT PAGE PROCESSING: hb pdf filename conflict on yoda'    

def finalize(pth):
    """Finalize handbook page."""
    hbe = HandbookEntry(source_dir=pth)
    if not hbe.will_clobber():
        err_msg = hbe.process_build()        
        return err_msg or 'did pdftk post-processing'
    else:
        return 'ABORT BUILD: hb pdf filename conflict on yoda'    

def main():
    # Get nautilus current uri
    curdir = os.environ.get('NAUTILUS_SCRIPT_CURRENT_URI', os.curdir)

    # Strip off uri prefix
    if curdir.startswith('file:///'):
        curdir = curdir[7:]
        
    # Verify curdir matches pattern (this works even in build subdir, a good thing)
    match = re.search( re.compile(_HANDBOOKDIR_PATTERN), curdir )
       
    # Do branching based on in build subdir or source_dir
    if match:
        #alert( match.string )
        if match.string.endswith('build'):
            msg = finalize( os.path.dirname(curdir) )
        else:
            msg = do_build(curdir)
    else:
        msg = 'ABORT: ignore non-hb dir'
        
    alert( '%s' % msg )

if __name__ == "__main__":
    main()
