#!/usr/bin/env bash
line=" 18 20 06 08 * /home/pims/adhoc/script.py &> /tmp/trash.txt # KEEP THIS COMMENT FOR ADHOC CONTROL" 
( crontab -l | grep -v "KEEP THIS COMMENT FOR ADHOC CONTROL"; echo "$line" ) | crontab -
