function cas = getsubdir(strDir,strPat)

% use regexp to get subdirs that fit pattern under input dir
%
% EXAMPLE
% strDir = 'C:\temp\fmri_testing\c1316plas_control';
% strPat = '^study_\w+';
% cas = getsubdir(strDir,strPat)

[files,dirs]=spm_select('List',strDir,'.*');
casDirs = cellstr(dirs);
c = regexpi(casDirs, strPat, 'names');
iKeep = findnonemptycells(c);
cas = casDirs(iKeep);