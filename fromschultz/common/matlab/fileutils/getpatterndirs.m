function casDirs = getpatterndirs(strPattern,strDir)
% GETPATTERNDIRS use regular expression to find dirs & output as cas
%
% EXAMPLE
% strPattern = '^series.*mocoseries$';
% strDir = 'C:\temp\fmri_data\originals\c1367plas_two\study_20090922';
% casDirs = getpatterndirs(strPattern,strDir);

% Get dir(s)
cas = getsubdirs(strDir);

% Get matching dirs using strPattern as regexp
casBases = cellfun(@basename,cas,'uni',false);
indMatch = findnonemptycells(regexpi(casBases,strPattern));
casDirs = cas(indMatch);