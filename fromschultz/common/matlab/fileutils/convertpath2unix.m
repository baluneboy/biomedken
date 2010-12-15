function strUnix = convertpath2unix(strWin,strFileExeCygpath)

% EXAMPLE
% strWin = 'c:\temp\fmri_data\originals\s1371plas\pre\';
% strUnix = convertpath2unix(strWin)
% strUnix = convertpath2unix(strWin,'c:\cygwin\bin\cygpath.exe')

%% Establish cygpath.exe
if nargin == 1
    sUtils = verifybashcygwinpython;
    strFileExeCygpath = sUtils.strFileExeCygpath;
end

%% Get "raw" output
[foo,strRaw] = dos([strFileExeCygpath ' -u ' strWin]);

%% Really should error check here...

%% Deblank [trailing?] blank
strUnix = deblank(strRaw);