#!/usr/bin/env bash

line=" 41 18 06 08 * /home/pims/adhoc/script.py > /tmp/trash.txt" 
( crontab -l | grep -v "/adhoc/"; echo "$line" ) | crontab -
