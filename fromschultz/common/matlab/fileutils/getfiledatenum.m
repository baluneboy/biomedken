function sdn = getfiledatenum(strFile)
f = dir(strFile);
sdn = f.datenum;