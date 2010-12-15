function copycasfileswithdirprefix(casFiles,strDirToPrefix,strToReplace)
% EXAMPLE
% casFiles = simpleglob('y:\adat\c*plas\pre\study_*\results\shoulder\w200*WHOLEHEAD*.img')
% strToReplace = 'y:\';
% strDirToPrefix = 'c:\temp\trash4kristen';
% copycasfileswithdirprefix(casFiles,strDirToPrefix,strToReplace)

strToReplace = fixpath(strToReplace);
strDirToPrefix = fixpath(strDirToPrefix);
casFilesTo = cellfun(@strrep,casFiles,cellstr(repmat(strToReplace,length(casFiles),1)),cellstr(repmat(strDirToPrefix,length(casFiles),1)),'uni',false);
casDirsTo = cellfun(@fileparts,casFilesTo,'uni',false);
warning('off','MATLAB:MKDIR:DirectoryExists')
cellfun(@mkdir,casDirsTo,'uni',false);
warning('on','MATLAB:MKDIR:DirectoryExists')
cellfun(@copyfile,casFiles,casDirsTo);