x

6. on jimmy, create symlink to target "ISS Handbook" on yoda as /home/pims/yodahb

7. see TODOs in handbook.py

8. make sure snippets are common [and/or abbreviations?] in komodo @home and @work

9. cropcat_middle: pdfjam 2013_10_11_08_00_00.000_121f03_spgs_roadmaps500.pdf --trim '3.05cm 0cm 5.5cm 0cm' --clip true --landscape --outfile middle.pdf



CREATE TABLE `Testing` (
  `TestingID` int(11) NOT NULL AUTO_INCREMENT,
  `Title` varchar(255) DEFAULT NULL,
  `Source` varchar(255) DEFAULT NULL,
  `FileName` varchar(255) DEFAULT NULL,
  `DateEntered` timestamp DEFAULT CURRENT_TIMESTAMP,
  `LastModified` date DEFAULT NULL,
  PRIMARY KEY (`TestingID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$


CREATE DEFINER=`pims`@`localhost` PROCEDURE `prototype`(IN title varchar(100), IN fname varchar(100))
BEGIN
    DECLARE today TIMESTAMP DEFAULT CURRENT_DATE;
    DECLARE source varchar(100);
    SET source = title;

    INSERT INTO Testing (LastModified, FileName, Title, Source) VALUES (today, fname, title, source);
END