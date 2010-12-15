function [allhtmllist,subIndexPath] = getallHtmlList(indexPath,searchFilename)
%GETALLHTMLLIST  Collect all the fxsummary.html pages.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula

if (nargin < 1), indexPath = 'H:\fxdownloads'; end
if (nargin < 2), searchFilename = 'fxsummary.html'; end

allhtmllist{1}='';
subIndexPath{1}=''; 
indexsubPath  = indexPath;
indexhtml = dir(fullfile(indexsubPath,searchFilename));
if ~isempty(indexhtml)
    allhtmllist{end+1} = fullfile(indexsubPath,searchFilename);
end

LocalDirs = dir(indexsubPath);
LocalDirs = LocalDirs(logical([LocalDirs.isdir]));
for j=1:length(LocalDirs)
    isdirexisting = checkdir(LocalDirs(j).name);
    indexhtml = dir(fullfile(indexsubPath,LocalDirs(j).name,searchFilename));
    if (~isempty(indexhtml)) && (isdirexisting)
        allhtmllist{end+1} = fullfile(indexsubPath,LocalDirs(j).name,searchFilename);
    end
    if isdirexisting
        files1 = dir(fullfile(indexsubPath,LocalDirs(j).name));
        files1 = files1(logical([files1.isdir]));
        for k=1:length(files1)
            isdirexisting = checkdir(files1(k).name);
            indexhtml = dir(fullfile(indexsubPath,LocalDirs(j).name,files1(k).name,searchFilename));
            indexsubPathhtml = dir(fullfile(indexsubPath,LocalDirs(j).name,'downloads_index.html'));
            if (~isempty(indexhtml)) && (isdirexisting)
                allhtmllist{end+1} = fullfile(indexsubPath,LocalDirs(j).name,files1(k).name,searchFilename);
                subIndexPath{end+1} = fullfile(indexsubPath,LocalDirs(j).name);
            elseif ~isempty(indexsubPathhtml)
                subIndexPath{end+1} = fullfile(indexsubPath,LocalDirs(j).name);
            end
        end
    end
end

%==========================================================================
function isdirexisting = checkdir(dirname)
%CHECKDIR  Check for directory.
if      ~strcmp(dirname(1),'.') && ...
        ~strcmp(dirname,'.') && ...
        ~strcmp(dirname,'..')
    isdirexisting = true;
else
    isdirexisting =  false;
end



