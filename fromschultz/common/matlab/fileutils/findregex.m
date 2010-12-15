function casFiles = findregex(strDir,strRegex)

% EXAMPLE
% strDir = 'c:\data\fmri\adat';
% strSession = 'preone';
% strTask = 'wrist';
% strRegex = ['.*[cs][0-9][0-9][0-9][0-9][a-z][a-z][a-z][a-z].' strSession '.study_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].series_[0-9][0-9]_' strTask '_.*_series_structure_' strTask '\.mat$'];
% casFiles = findregex(strDir,strRegex)

%% Get cygpath for use with find
strCmdCygpath = ['C:\cygwin\bin\cygpath.exe "' strDir '"'];
[foo,strDirCyg] = dos(strCmdCygpath);
strDirCygpath = deblank(strDirCyg);

%% Do find on mat files (returning cygpaths)
% find /cygdrive/c/data/fmri/adat -type f -regex '.*[cs][0-9][0-9][0-9][0-9][a-z][a-z][a-z][a-z].pre.study_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].series_[0-9][0-9]_shoulder_.*_series_structure_shoulder\.mat$' -exec cygpath -w {} \;
strCmd = ['C:\cygwin\bin\find.exe ' strDirCygpath ' -type f -iregex ' strRegex];
fprintf('\nUsing following cygwin command to find files:\n%s...',strCmd) 
[foo,strBig] = dos(strCmd);

%% Split str output from dos call into cas
casFiles = strsplit(char(10),strBig); % char(10) is CR/LF

%% Remove empty cells
casFilesCygpath = casFiles(findnonemptycells(casFiles))';

%% Convert to cygpath
casFiles = cellfun(@cygpath,casFilesCygpath,'uni',false);
fprintf('\ndone.\n')