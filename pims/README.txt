5. log entry after build (or just after success on insert?)

6. make all log.process calls (info or error or warn) as sentences ending in period or bang or ?

7. see TODOs in handbook.py

8. make sure snippets are common [and/or abbreviations?] in komodo @home and @work

9. cropcat_middle: pdfjam 2013_10_11_08_00_00.000_121f03_spgs_roadmaps500.pdf --trim '3.05cm 0cm 5.5cm 0cm' --clip true --landscape --outfile middle.pdf

# FIXME the following err_msg prefix propagation is ugly
root     : INFO    : Logging started at 2013-10-20 09:43:05.068513.
PROCESS  : INFO    : Parsed source_dir string: regime:Vibratory, category:Vehicle, and title:Big Bang
PROCESS  : INFO    : Attempting process_build in /home/pims/Documents/test/hb_vib_vehicle_Big_Bang/build
PROCESS  : INFO    : Ran HandbookPdftkCommand (unoconv and offset/scale) for 2 odt files
PROCESS  : INFO    : We now have 3 unjoined files, including ancillary file
PROCESS  : INFO    : Attempting to finalize_entry
PROCESS  : INFO    : Renamed hb_pdf with time stamp
PROCESS  : INFO    : Ran pdfjoin command to get /home/pims/Documents/test/hb_vib_vehicle_Big_Bang/hb_vib_vehicle_Big_Bang.pdf
PROCESS  : INFO    : Did the unbuild okay
PROCESS  : ERROR   : Database problem hb_vib_vehicle_Big_Bang.pdf already exists in one of the records
PROCESS  : ERROR   : db_insert error db_insert err_msg is Database problem hb_vib_vehicle_Big_Bang.pdf already exists in one of the records
process_build err_msg is finalize_entry err_msg is db_insert err_msg is Database problem hb_vib_vehicle_Big_Bang.pdf already exists in one of the records

