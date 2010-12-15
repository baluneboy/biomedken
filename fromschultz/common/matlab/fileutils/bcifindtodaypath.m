function casDirs = bcifindtodaypath(strDirTop,strWild)

% BCIFINDTODAYPATH find path(s) of files newer than start of today
%
% casDirs = bcifindtodaypath(strDirTop,strWild);
%
% INPUTS:
% strDirTop - string for topmost (parent) directory to search
% strWild - string wildcards for files to find
%
% OUTPUTS:
% casDirs - cell array of strings with paths for "today files"
%
% NOTE: this routine relies on 2 environment variables:
%       1. CYGBINPATH - path to cygwin util routines (for example, c:\cygwin\bin)
%       2. BASHPATH - path to bash scripts (for example, e:\workcopy\scripts\trunk\bash)
%
% EXAMPLE
% strDirTop = 'e:/Data/BCI/Therapy';
% strWild = '*.dat';
% casDirs = bcifindtodaypath(strDirTop,strWild)

% Author: Ken Hrovat
% $Id: bcifindtodaypath.m 4160 2009-12-11 19:10:14Z khrovat $

% Fix slash for cygwin
strDirTop = strrep(strDirTop,'\','/');

% Get some environment variables
strDirCygBin = getenv('CYGBINPATH');
strDirBash = getenv('BASHPATH');

% Verify cygwin utils are where expected
strExeBash = fullfile(strDirCygBin,'bash.exe');
locVerifyFile(strExeBash);
strExeCygpath = fullfile(strDirCygBin,'cygpath.exe');
locVerifyFile(strExeCygpath);
strExeFind = fullfile(strDirCygBin,'find.exe');
locVerifyFile(strExeFind);

% Verify bash script exists where expected
strScriptBash = fullfile(strDirBash,'findtodayfiles.bash');
locVerifyFile(strScriptBash);

% Build command to find today files
strCmd = [strExeBash ' -l ' strScriptBash ' ' strDirTop ' "' strWild '"'];
fprintf('\nUsing the following command to find "today path":\n%s\n',strCmd) % comment this line out if it's annoying

% Execute command to find today files
[foo,str] = dos(strCmd);

% Split str output from dos call into cas
casSplit = strsplit(char(10),str); % char(10) is CR/LF

% Remove empty cells
casSplit(findemptycells(casSplit)) = [];

% Get path names (strip off filenames)
casDirs = cellfun(@(x)fileparts(x),casSplit,'uniform',false);

% Remove redundancies and make it a "column cas"
casDirs = unique(casDirs)';

%------------------------------
function locVerifyFile(strFile)
if ~exist(strFile,'file')
    error('daly:bci:missingFile','%s not found',strFile)
end