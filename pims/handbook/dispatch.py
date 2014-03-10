#!/usr/bin/env python

# For new handbook PDF type, do the following:
# 1. In pims.patterns.handbookpdfs, add new UNIQUE regex pattern and...
#    be sure pattern varname ends with "PDF_PATTERN", but does NOT start with "_HANDBOOK".
# 2. In pims.files.handbook, use existing class (if possible), or add new class for new pattern.
# 3. In __main__ here, add example/new filename to "files" and run to see if it checks out here.

"""
Dispatch pattern -> class for handbook pages.
"""
import re
import warnings
import pims.files.handbook as hb            # classes
import pims.patterns.handbookpdfs as hbpat  # patterns
from pims.gui.multichoice_dialog import MultiChoiceFilterFileDialog

# convert camel-case name to underscore pattern name
def camelname_to_patname(cname):
    pname = '_' + cname.upper() + '_PATTERN'
    return pname

# we want hb classes that end with "Pdf", but not start with "Handbook"
def get_map_regexp_class():
    map_regexp_class = {}
    dhb = [c for c in dir(hb) if c.endswith('Pdf') and not c.startswith('Handbook')]
    for hb_class_name in dhb:
        regexp_name = camelname_to_patname(hb_class_name)
        the_class = getattr(hb, hb_class_name)
        the_pattern = getattr(hbpat, regexp_name)
        map_regexp_class[re.compile(the_pattern)] = the_class
    return map_regexp_class

# map filename via unique pattern match to its class
def map_fname_pat_to_class(s):
    """map filename via unique pattern match to its class"""
    
    # get dict that maps regexp to class
    map_regexp_class = get_map_regexp_class()
    
    # match each regex on the string
    matches = ( (c, regex.match(s)) for regex, c in map_regexp_class.iteritems() )
    
    # filter out empty (non) matches, and extract groups
    match_list = [ (c, match.groups()) for c, match in matches if match is not None ]
    
    # verify unique pattern match
    if len(match_list) != 1:
        warnings.warn( 'DO NOT have unique handbook pattern match for %s' % s )    
        klass = None
        args = None
    else:
        # since only one, pull class, mgroups off list
        klass, args = match_list[0]
    return klass, args

def show_matches(fullnames):
    """Map via dictionary with fname regexp pattern as key and class name as value"""
    for f in fullnames:
        klass, args = map_fname_pat_to_class(f)
        print f, klass, args

def is_unique_hb_pdf(fname):
    klass, args = map_fname_pat_to_class(fname)
    if klass:
        return True
    else:
        return False
    
class HandbookFileDialog(MultiChoiceFilterFileDialog):

    def __init__(self, files):
        # we will use this predicate for preselect method
        self.predicate = is_unique_hb_pdf
        super(MultiChoiceFilterFileDialog, self).__init__('Handbook File Dialog', "All checked to continue, right?", files)
    
    def all_match(self):
        """Return True if all unique matches for handbook patterns; else return False."""
        idx = [ i for i, f in enumerate(self.choices) if self.predicate(f) ]
        self.dialog.SetSelections(idx)

if __name__ == '__main__':

    from pims.gui.multichoice_dialog import MultiChoiceFilterFileDialog
    from pims.files.utils import listdir_filename_pattern

    files = listdir_filename_pattern('/misc/yoda/www/plots/user/handbook/source_docs/hb_vib_equipment_Columbus_GLACIER-3',
                                     hbpat._HANDBOOKPDF_PATTERN[3:])

    #files = [
    #    '/tmp/1qualify_2013_12_19_08_00_00.000_121f03_spgs_roadmaps500_cmg_spin_downup.pdf',
    #    '/tmp/5quantify_2013_10_08_13_35_00_es03_cvfs_msg_wv3fans_compare.pdf',
    #    '/tmp/1qualify_2013_10_01_00_00_00.000_121f05_pcss_roadmaps500.pdf',
    #    '/tmp/x3quantify_2013_09_22_121f03_irmss_cygnus_fan_capture_31p7to41p7hz.pdf',
    #    '/tmp/1quantify_2013_12_11_16_20_00_ossbtmf_gvt3_progress53p_reboost.pdf',
    #    '/tmp/1qualify_2011_05_19_18_18_00_121f03006_gvt3_12hour_pm1mg_001800_12hc.pdf',
    #    '/tmp/2quantify_2011_05_19_18_18_00_121f03006_gvt3_12hour_pm1mg_001800_hist.pdf',
    #    '/tmp/x3quantify_2011_05_19_00_08_00_121f03006_gvt3_12hour_pm1mg_001800_z1mg.pdf',
    #    '/misc/yoda/www/plots/user/handbook/source_docs/hb_vib_vehicle_CMG_Desat/1quantify_2011_05_19_18_18_00_121f03006_gvt3_12hour_pm1mg_001800_12hc.pdf',
    #    '/tmp/x3quantify_2014_03_03_14_30_00_121f08_rvts_glacier3_duty_cycle.pdf',
    #    ]
    #show_matches(files)
       
    title = "Demo Class MultiChoiceFilterFileDialog"
    prompt = "Pick from\nthis file list:"
    dialog = HandbookFileDialog(files)
    user_selections = dialog.show_dialog()    
    
    if user_selections is None:
        print 'you pressed cancel'        
    elif len(user_selections) == 0:
        print 'you chose nothing'
    else:
        print user_selections