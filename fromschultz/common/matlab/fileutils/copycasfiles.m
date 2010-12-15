function copycasfiles(casFiles,strDirTo)
% EXAMPLE
% casFiles = dirbs('s:\data\upper\clinical_measures\*hart*.xls');
% strDirTo = 'c:\temp\trash4kristen';
% copycasfiles(casFiles,strDirTo)
casDirsTo = cellstr(repmat(strDirTo,length(casFiles),1));
cellfun(@copyfile,casFiles,casDirsTo);