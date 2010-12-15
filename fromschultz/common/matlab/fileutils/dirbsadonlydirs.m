function casDirs = dirbsadonlydirs(strWildstar)

% do windows' "dir blah /b /s /ad"
%
% INPUTS:
% strWildstar - string wild for [drive][path] to search
%
% OUTPUTS:
% cFilenames - cell array of cFilenames
% sDetails - structure of dir info
%
% EXAMPLE:
% % to do windows cmd: dir c:\temp\fmri_data\originals\pre /b /s /ad
% casDirs = dirbsadonlydirs('c:\temp\fmri_data\originals\pre');

% AUTHOR: Ken Hrovat
% $Id$

if ~ispc
    error('this only works on Windows [say whaaaaaaat]')
end

strCmd = sprintf('dir %s /b /s',strWildstar);
[junk,strHuge] = dos(strCmd);
casDirs = strsplit(10,strHuge);
iEmpty = findemptycells(casDirs);
casDirs(iEmpty) = [];
casDirs = sort(casDirs'); % transpose to column form
if strcmp(casDirs,'File Not Found')
    casDirs = {};
end
if isempty(casDirs), return; end
iToss = ~cellfun(@isdir,casDirs);
casDirs(iToss) = [];