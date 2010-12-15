function movecasfiles(casFiles,strDirTo)
% EXAMPLE
% casFiles = {'c:\temp\trash.txt'; 'c:\temp\trash2.txt'};
% strDirTo = 'c:\temp\destdir';
% movecasfiles(casFiles,strDirTo)
casDirsTo = cellstr(repmat(strDirTo,length(casFiles),1));
cellfun(@movefile,casFiles,casDirsTo);