5. make all log.process calls (info or error or warn) as sentences ending in period or bang or ?

6. on jimmy, create symlink to target "ISS Handbook" on yoda as /home/pims/yodahb

7. see TODOs in handbook.py

8. make sure snippets are common [and/or abbreviations?] in komodo @home and @work

9. cropcat_middle: pdfjam 2013_10_11_08_00_00.000_121f03_spgs_roadmaps500.pdf --trim '3.05cm 0cm 5.5cm 0cm' --clip true --landscape --outfile middle.pdf



-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `auto_insert_handbook`(filename varchar(50), title varchar(50), regime varchar(16), category varchar(16))
BEGIN

    #############################################
    # Do not change these:
    set @doctypeid = 49;    #PDF
    set @catid = 1;         #ISS Handbook Page
    #############################################

    CASE LOWER(regime)
        WHEN 'vibratory' THEN
            set @regime = 'Vibratory';
        WHEN 'quasi-steady' THEN
            set @regime = 'Quasi-steady';
        ELSE
            set @regime = 'Vibratory';
    END CASE;

    CASE LOWER(category)
        WHEN 'crew' THEN
            set @hbcat = 1;
        WHEN 'vehicle' THEN
            set @hbcat = 2;
        ELSE
            set @hbcat = 3; # assumed to be equipment here
    END CASE;

    INSERT INTO Document (DocumentTypeID,CategoryID,Title,FileName,Authors,PubDate,Access,PIMSAuthored,Location,DateEntered,EnteredBy,LastModified,ModifiedBy)
    VALUES (@doctypeid,@catid,@title,@filename,'Ken Hrovat',curdate(),'public','Yes','public/ISS Handbook/',curdate(),126,curdate(),6);

    SELECT LAST_INSERT_ID() INTO @docid;

    IF (@docid > 0) THEN 
        INSERT INTO Handbook (Source,Regime,HBCategoryID,DocumentID) VALUES (@title,@regime,@hbcat,@docid);
    END IF;

END

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

