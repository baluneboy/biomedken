
x. during post-processing, for ancillary ODT(s), figure out how to skip offset pdftk part, just do unoconv odt to "_pdftk.pdf" for inclusion

x. Have hbe.process_build() at the end after "hb_OUT.pdf" file is created, do unbuild

x. document in each related file how to update including the guess_file list (c'mon man)

x. DBQ [more like PAD interval finder to get first header] based on sensor and datetime to get header type info (as much as makes sense)...pull in PAD python code for headers here?

5. 121f03006 PadHeader seems to be using 121f03 as sensor instead of 121f03006

6. do these next 3 things:
- svn tag BEFORE doing anything below here!!!
- svn mv the subdirs under core up one to be under pims
- svn delete core
- scrub code under pims for references to pims.core and change those to pims

7. make sure snippets are common [and/or abbreviations?] in komodo @home and @work

8. cropcat_middle: pdfjam 2013_10_11_08_00_00.000_121f03_spgs_roadmaps500.pdf --trim '3.05cm 0cm 5.5cm 0cm' --clip true --landscape --outfile middle.pdf
