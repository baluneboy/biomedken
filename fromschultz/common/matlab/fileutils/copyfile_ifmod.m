function copyfile_ifmod(sourcefile,destinationfile)

% COPYFILE_IFMOD Copies a file, checking for modifications first if target exists
%
% USAGE:
%  copyfile_ifmod(src,dest);
%
% INPUTS:
%  sourcefile - path to source file
%  destinationfile - path to destination file
%
% OUTPUTS:
%  If destination file does not exist, or differs from source file, creates destinationfile
%  Otherwise, does nothing
%
% NOTES: Checking for "differences" is done by comparing timestamp and file size; if either
%  shows a mismatch, files are assumed to be different (there might be a better way to do this,
%  but I have not found anything yet).

% AUTHOR: Roger Cheng
% $Id: copyfile_ifmod.m 4160 2009-12-11 19:10:14Z khrovat $

if ~exist(sourcefile)
    error('copyfile_ifmod:FNF','Source file not found');
end
% Get size and timestamp using dir
dsrc = dir(sourcefile);
ddest = dir(destinationfile);

% Check for differences, and copy
if isempty(ddest) || or(~isequal(ddest.datenum,dsrc.datenum),~isequal(dsrc.bytes,ddest.bytes))
    copyfile(sourcefile,destinationfile);
% else
%     warning('File not copied (no differences found between src and dest)');
end