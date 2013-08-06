#!/usr/bin/env bash

line=" 21 19 05 08 * /home/pims/adhoc/script.py > /tmp/trash.txt" 
( crontab -l | grep -v "/adhoc/"; echo "$line" ) | crontab -
