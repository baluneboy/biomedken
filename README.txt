1. @home cp /home/pims/dev/programs/python/handbook/handbook_template.odt /home/pims/dev/programs/python/pims/templates/handbook_template.odt

2. somehow before pre-processing, figure out how to init create MAXPLUSONEancillary ODT in source_dir via special ancillary template

3. during post-processing, for ancillary ODT(s), figure out how to skip offset pdftk part, just do unoconv odt to "_pdftk.pdf" for inclusion

4. DBQ based on sensor and datetime to get header type info (as much as makes sense)...pull in PAD python code for headers here?

5. svn mv the subdirs under core up one to be under pims
6. svn delete the __init__.py in core
7. scrub code under pims for references to pims.core and change those to pims