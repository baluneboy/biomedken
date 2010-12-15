function [files, dirs] = recursiveGetFiles(rootPath, varargin)
% RECURSIVEGETFILES -- function to recursively return filepaths and directories from a root path
% 
% Inputs:
%     rootPath -- The top level directory to search
%     extension(OPTIONAL) -- file extension filter
% 
% Outputs:
%     files -- cell array of strings of filepaths in top level directory and all sub directories
%     dirs -- all sub directories in top level directory
%     
% Example:
%     datadir = 'S:\data\upper\bci\therapy\c9999rand';
%     [files, dirs] = recursiveGetFiles(datadir, '.prm');

% Author: Sahil Grover

% optional file extension filter
ext = '*';
if nargin>1
    ext = [varargin{1}];
    if isempty(strfind(ext,'*'))
        ext = ['*' ext];
    end
end

[filenames, details] = dirdeal(rootPath);

% get indices of directories
[dirInd{1:length(details)}] = deal(details.isdir);
dirInd = cell2mat(dirInd);
filenames = filenames(dirInd);
dirs =  cellfun(@(x)[rootPath filesep x],filenames,'uni',0);

[rawFiles,fDetails] = dirdeal([rootPath filesep ext]);
[filesInd{1:length(fDetails)}] = deal(fDetails.isdir);
filesInd = ~cell2mat(filesInd);
files = rawFiles(filesInd);
files = cellfun(@(x)[rootPath filesep x],files,'uni',0);

for i=1:length(dirs)
    [f, d] = recursiveGetFiles(dirs{i},ext);
    files = [files; f];
    dirs = [dirs; d];
end