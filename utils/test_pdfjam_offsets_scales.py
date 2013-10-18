#!/usr/bin/env python

from pims.files.pdfs.pdfjam import PdfjamCommand
from pims.files.pdfs.pdftk import convert_odt2pdf, PdftkCommand
from appy.pod.renderer import Renderer

fullsize_pdf = '/tmp/testing/2013_10_09_00_00_00.000_121f04_spgs_roadmaps500.pdf'
odt_template = '/home/pims/dev/programs/python/pims/templates/pdfjam_template_offsets_scales_testing.odt'

#pdftk unoconv_odtfile.pdf background unoconv_odtfile_offset_-4.25cm_1cm_scale_0.88.pdf output updir/hb_regime_category_title.pdf

#scales =    [x/100.0 for x in range(80,100,5)]
#xoffsets =  [x/100.0 for x in range(-425,-250,50)]
#yoffsets =  [1.5, 1.0, 0.0]

#scales =    [x/100.0 for x in range(86, 89, 1)]
#xoffsets =  [x/100.0 for x in range(-435,-415, 10)]
#yoffsets =  [1.25, 1.00, 0.75]

scales =    [86/100.0]
xoffsets =  [-425/100.0]
yoffsets =  [1.00]

for scale in scales:
    for xoffset in xoffsets:
        for yoffset in yoffsets:
            
            pdfjam_cmd = PdfjamCommand(fullsize_pdf, xoffset=xoffset, yoffset=yoffset, scale=scale, log=None)
            pdfjam_cmd.run()
            
            offset_pdfname = pdfjam_cmd.outfile
            odt_name = offset_pdfname.replace('.pdf', '_fg.odt')
            
            # Explicitly assign page_dict that contains expected names for appy/pod template substitution
            page_dict = {'scale': scale, 'xoffset': xoffset, 'yoffset': yoffset}
            odt_renderer = Renderer( odt_template, page_dict, odt_name )
            odt_renderer.run()
            
            convert_odt2pdf(odt_name)
            
            pdftk_cmd = PdftkCommand(odt_name.replace('.odt', '.pdf'), offset_pdfname, offset_pdfname.replace('.pdf', '_pdftk.pdf'))
            pdftk_cmd.run()
