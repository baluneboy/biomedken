SELECT count(*) FROM pims.121f03 where time>unix_timestamp('2013-10-23 18:45:01') and time<unix_timestamp('2013-10-25 00:05:34');

3. add cronjob on jimmy for backfill_ossbtmf_roadmap.py with better default args

4. verify MANUALLY that copy PDF to ~/yodahb/ path, then auto_insert_handbook SQL yields web page end item, then
verify handbook.py does things in right order (copy file first, then auto_insert_handbook)

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

========================================================
obspy header info
========================================================

network = system (sams, mams, etc.)
station = sensor (121f05, 0bbd, etc.)
location = SensorCoordinateSystem's comment field
channel = X,Y,Z for SSA (or A,B,C for sensor)

Agency.Deployment.Station.Location (Channel)

CHANNEL CHAR 1
F (unknown description)		fs >= 1000 and fs < 5000
C (unknown description)		fs >= 250 and fs < 1000
E (Extremely Short Period)	fs >= 80 and fs < 250
S (Short Period)			fs >= 10 and fs < 80

CHANNEL CHAR 2
N (Accelerometer)

CHANNEL CHAR 3
A B C (SSA's X, Y, Z)
1 2 3 (sensor's X, Y, Z)

NASA.ISS.SAMS.05.CNA for SAMS, SE-05,  500 sps, X-axis
NASA.ISS.SAME.03.CNB for SAMS, ES-06,  500 sps, Y-axis
NASA.ISS.MAMS.HI.FNC for MAMS, HiRAP, 1000 sps, Z-axis

See sandbox/flatbook_demo.py for starter kit on upgrade to "pads" & "roadmaps" tally_grid workers.  The big deal will
be if (1) PADs gets populated first, (2) then roadmaps after that, (3) then some form of link between the 2 grids so
that processing cells in PADs may have resample hooked to it, but also the ability to highlight PAD cells that have some
hours, but where no roadmaps exist, then there's good way to process those cells (in PADs) to create the missing roadmaps FTW!
