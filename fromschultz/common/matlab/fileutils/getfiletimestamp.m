function strTimestamp = getfiletimestamp(strFile)
f = dir(strFile);
strTimestamp = datestr(f.datenum,29);