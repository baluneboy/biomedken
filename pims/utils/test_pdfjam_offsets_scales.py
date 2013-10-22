#!/usr/bin/env python

from pims.files.pdfs.pdfjam import PdfjamCommand
from pims.files.pdfs.pdftk import convert_odt2pdf, PdftkCommand
from appy.pod.renderer import Renderer

fullsize_pdf = '/tmp/4quantify_2013_09_28_16_radgse_roadmapnup1x2.pdf'
odt_template = '/tmp/1qualify_2013_09_28_08_ossbtmf_roadmap_bigpic.odt'

#pdftk unoconv_odtfile.pdf background unoconv_odtfile_offset_-4.25cm_1cm_scale_0.88.pdf output updir/hb_regime_category_title.pdf

scales =    [x/100.0 for x in range(74,80,2)]
xoffsets =  [x/100.0 for x in range(-300,-150,50)]
yoffsets =  [1.5, 1.0, 0.0]

#scales =    [x/100.0 for x in range(86, 89, 1)]
#xoffsets =  [x/100.0 for x in range(-435,-415, 10)]
#yoffsets =  [1.25, 1.00, 0.75]

#scales =    [86/100.0]
#xoffsets =  [-425/100.0]
#yoffsets =  [1.00]

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
