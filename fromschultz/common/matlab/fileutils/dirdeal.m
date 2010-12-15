function [cFilenames,sDetails]=dirdeal(strFolder)
% DIRDEAL - Function to return sorted filenames (that do not start with a
% leading dot).
%
% INPUTS:
% strFolder - string for directory to search
%
% OUTPUTS:
% cFilenames - cell array of cFilenames
% sDetails - structure of dir info
%
% EXAMPLE:
% [cFilenames,sDetails]=dirdeal('C:\Documents and Settings\Owner\My Documents\daly\Control\I Deal');

% AUTHOR: Ken Hrovat
% $Id: dirdeal.m 4160 2009-12-11 19:10:14Z khrovat $

% Get raw details as structure
sDetails=dir(strFolder);

% Populate cell array of filenames
cFilenames={};
if isempty(sDetails)
   return
end
[cFilenames{1:length(sDetails),1}]=deal(sDetails.name);

% Remove files with leading dot
i=strmatch('.',cFilenames);
cFilenames(i)=[];
sDetails(i)=[];

% Only had leading dotted ones, so return nothing
if isempty(sDetails)
    return
end

% Sort outputs
[cFilenames,isort]=sort(cFilenames);
sDetails=sDetails(isort);

% Get path to prepend for pathstr in details structure
[strPath,fname,fext,fver]=fileparts(strFolder);
strPath=[strPath filesep fname];
[sDetails.pathstr]=deal(strPath);