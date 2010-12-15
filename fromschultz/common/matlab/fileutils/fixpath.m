function strPath=fixpath(str)

% remove trailing filesep if it exists (for consistent path handling)
%
% strPath=fixpath(str);
%
% Inputs
% str - string for path with or without trailing filesep
%
% Outputs
% strPath - string same as str but without trailing filesep
%
% Example
% strSessionPath='/home/analysis2/robotics_data/s_rihafplas/RawData/20051202_Fri_pre/';
% fixpath(strSessionPath)

% $Author$ Hrovat
% $Id: fixpath.m 4160 2009-12-11 19:10:14Z khrovat $

% Be nice about trailing filesep
strPath=str;
if strcmp(strPath(end),filesep)
    strPath(end)=[];
end