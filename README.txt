pims@jimmy:~/dev/programs/python/pims$ type sdiff
sdiff is aliased to `svn diff --diff-cmd=meld' # in .bashrc (why not .profile?)

# SEE pdftk SYNTAX BELOW
# /misc/yoda/www/plots/user/handbook/source_docs/hb_qs_equipment_Robonaut_Goes_Off
# pdfjam --offset '-4.25cm 1cm' --scale 0.85 2013_10_01_00_00_00.000_121f02ten_spgs_roadmaps500.pdf --landscape --outfile myhandout_offset_-4p25_1.pdf
# pdftk handbook_template.pdf background myhandout_offset_-4p25_1.pdf output out.pdf
#
# pdfjam --offset '-4.25cm 1cm' --scale 0.85 3qualify_2013_10_01_08_00_00.000_121f03one_spgs_roadmaps142.pdf --landscape --outfile offset_example_-4p25_1.pdf
# pdftk handbook_template.pdf background offset_example_-4p25_1.pdf output out.pdf
#
# pdfjam --offset '-2.75cm 0.75cm' --scale 0.88 1quantify_ossbtmf_gvt3.pdf --landscape --outfile offset_example_offset_-2p75_0p75_scale_0p88.pdf
# pdftk atv4_reboost_quantify.pdf background offset_example_offset_-2p75_0p75_scale_0p88.pdf output page1_atv4_reboost_quantify.pdf