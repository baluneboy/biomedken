function [stat,str] = rsync2sdrive(strOpts,strDirSrc,strDirDes)

%
% EXAMPLE
% strOpts = '-avn';
% strDirSrc = '/cygdrive/c/temp/fmri_local/';
% strDirDes = '/cygdrive/s/data/upper/fmri/fmri_local/';
% [stat,str] = rsync2sdrive(strOpts,strDirSrc,strDirDes);

% For convenience
stat = 0;
if nargin == 0
    strOpts = '-av';
    strDirSrc = '/cygdrive/c/temp/fmri_local/';
    strDirDes = '/cygdrive/s/data/upper/fmri/fmri_local/';
end
%strExclude = ' --exclude=*.ppt';

% Verify runsheet csv file exists
strExe = 'c:\cygwin\bin\rsync.exe';
if ~exist(strExe)
    warning('PathTests:exeExist','the following EXE file does not exist \n%s',strExe)
    return % stat = 0
end

% Build command line
strCmd = [strExe ' ' strOpts ' ' strDirSrc ' ' strDirDes];
[stat,str] = unix(strCmd);