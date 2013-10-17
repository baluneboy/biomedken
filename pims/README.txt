x. somehow before pre-processing, figure out how to init create MAXPLUSONEancillary ODT in source_dir via special ancillary template

x. during post-processing, for ancillary ODT(s), figure out how to skip offset pdftk part, just do unoconv odt to "_pdftk.pdf" for inclusion

x. Have hbe.process_build() at the end after "hb_OUT.pdf" file is created, do unbuild

x. document in each related file how to update including the guess_file list (c'mon man)

5. DBQ [more like PAD interval finder to get first header] based on sensor and datetime to get header type info (as much as makes sense)...pull in PAD python code for headers here?

6. do these next 3 things:
- svn tag BEFORE doing anything below here!!!
- svn mv the subdirs under core up one to be under pims
- svn delete core
- scrub code under pims for references to pims.core and change those to pims

7. make sure snippets are common [and/or abbreviations?] in komodo @home and @work
