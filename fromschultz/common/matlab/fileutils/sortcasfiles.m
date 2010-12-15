function [casSort,iSort] = sortcasfiles(casFiles,strPrefix)
% SORTCASFILES.M - takes care of files with unsorted numbering or
% different length of numbers [i.e., 99 and 100 instead of 099 and 100]
% 
% INPUTS
% casFiles - list of files to sort
% 
% OUTPUTS
% casSort - list of sorted filenames [same size as casFiles]
% 
% EXAMPLE
% strDir = 'S:\data\upper\vicon\dalyUE\upperStroke\s1370plas\20091221_s1370plas';
% strPat = 'Supination_pronation.*c3d$';
% casFiles = getpatternfiles(strPat,strDir,'cas');
% strPrefix = 'supination_pronation';
% casSort = sortcasfiles(casFiles,strPrefix);

% Author - Krisanne Litinas
% $Id$

% convert strPrefix to cell, then repeat to match size of casFiles
casPrefix = repmat({strPrefix},length(casFiles),1);

% call locgetnum to do regular expression matching
cas = cellfun(@locgetnum,casFiles,casPrefix,'uni',0);

% str2double the cas
iFile = cellfun(@str2double,cas);

[foo, iSort] = sort(iFile);
casSort = casFiles(iSort);

%-----------------------------------
function n = locgetnum(str,strPrefix)
strBase = basename(str);
strPattern = ['^' strPrefix '\D*(?<num>\d{1,3})$'];
x = regexpi(strBase,strPattern,'names');
n = x.num;
