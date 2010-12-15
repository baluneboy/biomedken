function deletefile(downloadDir,isfromMainIndex)
%DELETEFILE  Delete a download directory.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula

if (nargin < 2), isfromMainIndex = 0; end

isdirExsting = isdir(downloadDir);
indexPath = fileparts(downloadDir);
if isdirExsting
    isOverWrite = questdlg('Are you sure you want to delete the file?','Delete file','Ok','Cancel','Ok');
    if isempty(isOverWrite)
        isOverWrite = 'Ok';
    end
    switch  lower(isOverWrite)
        case 'ok'
            cd(indexPath);
            rmdir(downloadDir,'s')
        case 'cancel'
            return
    end
end

newfilePath = downloadDir;
for counter = 1:4
[newfilePath newfileName] = fileparts(newfilePath);
indexFilename = dir(fullfile(newfilePath,newfileName,'downloads_index.html'));
    if ~isempty(indexFilename) && strcmp(newfileName,'fxdownloads')
        updatefxindex(fullfile(newfilePath,newfileName,indexFilename.name),0);
        break;
    end
end
if isfromMainIndex
    web(fullfile(newfilePath,newfileName,indexFilename.name));
else
    web(fullfile(fileparts(downloadDir),'downloads_index.html'));
end