function showfxdownloads(indexPath)
%SHOWFXDOWNLOADS  Open fxdownloads index page.
%
%   SHOWFXDOWNLOADS opens fxdownloads index page. By default it will get the
%   path from the preference set.
%
%   SHOWFXDOWNLOADS(indexPath) opens fxdownloads index page of specified
%   path.
%
%   Example:
%     showfxdownloads('H:\fxdownloads')

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula

if (nargin < 1), indexPath = ''; end

%get the indexPath from the preference already set if indexPath is not
%passed
if ispref('fileexchange','prefindexPath') && isempty(indexPath)
    indexPath = getpref('fileexchange','prefindexPath');
end

if ~isempty(indexPath)
    indexFilename = dir(fullfile(indexPath,'downloads_index.html'));
    if ~isempty(indexFilename)
        web(fullfile(indexPath,indexFilename.name),'-new');
    else
        msgbox('No downloads available');
    end
else
    msgbox('No directory has been choosen.');
end