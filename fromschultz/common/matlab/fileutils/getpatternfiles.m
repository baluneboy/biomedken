function casFiles = getpatternfiles(strPattern,strDir,strType)

% use regular expression to find files & output as cas
%
% EXAMPLE
% strPattern = '^a20.*bold.*\w+_(?<num>\d{2,3})\.img$';
% strDir = pwd;
% strType = 'cas'; % or 'char'
% casFiles = getpatternfiles(strPattern,strDir,strType);

% Get dir
strDir = [ fixpath(strDir) filesep ];

% Get matching files using strPattern as regexp
casFiles = {};
[files,dirs] = spm_select('List',strDir,strPattern);
if isempty(files), return, end

switch lower(strType)
    case 'cas'
        casFiles = strcat(strDir,cellstr(files));
    case 'char'
        casFiles = {strcat(strDir,files)};
end