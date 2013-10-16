x. somehow before pre-processing, figure out how to init create MAXPLUSONEancillary ODT in source_dir via special ancillary template

x. during post-processing, for ancillary ODT(s), figure out how to skip offset pdftk part, just do unoconv odt to "_pdftk.pdf" for inclusion

3. Have hbe.process_build() at the end after "hb_OUT.pdf" file is created, do a reset, like in rebuild -- which is:
        # TODO
        # delete *_pdftk.pdf files
        # toss *.pdf files that have matching .odt file
        # get rid of \dancillary_.*\.pdf
        # rename \dancillary_.*\.odt WITHOUT leading page num digit
        # get rid of hb_OUTFILE.pdf in source_dir  <<<< DO NOT DO THIS PART FOR RESET, ONLY FOR REBUILD!

4. DBQ based on sensor and datetime to get header type info (as much as makes sense)...pull in PAD python code for headers here?

5. svn mv the subdirs under core up one to be under pims
6. svn delete core
7. scrub code under pims for references to pims.core and change those to pims
