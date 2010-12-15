function casFiles = dirbs(strWildstar)

% do windows' "dir blah /b /s"
%
% INPUTS:
% strWildstar - string wild for directory to search
%
% OUTPUTS:
% cFilenames - cell array of cFilenames
% sDetails - structure of dir info
%
% EXAMPLE:
% % to do windows cmd: dir s:\data\upper\clinical_measures\*fugl*.xls /b /s
% casFiles = dirbs('s:\data\upper\clinical_measures\*fugl*.xls');

% AUTHOR: Ken Hrovat
% $Id: dirbs.m 4160 2009-12-11 19:10:14Z khrovat $

if ~ispc
    error('this only works on Windows [imagine that]')
end

strCmd = sprintf('dir %s /b /s',strWildstar);
[junk,strHuge] = dos(strCmd);
casFiles = strsplit(10,strHuge);
iEmpty = findemptycells(casFiles);
casFiles(iEmpty) = [];
casFiles = sort(casFiles'); % transpose to column form