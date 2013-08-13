# 1. Make changes in the replace these values section
# 2. Choose Script->Execute to run
# 3. Verify by querying handbook table

use pimsdoc;

##Replace these values
set @title = 'DECLIC Turns Off'; #Title
set @filename = 'hb_vib_equipment_declic-turns-off.pdf'; #Filename
set @author = 'Ken Hrovat'; #Author
set @pubdate = '2011-12-28'; #Publication date

# Regime is Vibratory or Quasi-steady
set @regime = 'Vibratory';

#Handbook category
#        Crew Activity = 1; 
#              Vehicle = 2
# Experiment Equipment = 3;
set @hbcat = 3;
set @source = 'DECLIC';


call insert_handbook(@title,@filename,@author,@pubdate,@regime,@hbcat,@source);
