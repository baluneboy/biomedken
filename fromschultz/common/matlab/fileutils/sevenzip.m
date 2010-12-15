function [status,result] = sevenzip(strFileArchive,strDirToZip)

% EXAMPLE
% strDirToZip = 'c:\temp\fmri_data\originals\s1369plas\s1369plas_preone';
% [foo,strName] = fileparts(strDirToZip);
% strFileArchive = fullfile(pdir(strDirToZip),[strName '_backup']);
% [status,result] = sevenzip(strFileArchive,strDirToZip)

strFileExeSevenZip = getenv('SEVENZIPEXE');
strCmd = ['"' strFileExeSevenZip '" a -tzip ' strFileArchive ' ' strDirToZip];
[status,result] = dos(strCmd);