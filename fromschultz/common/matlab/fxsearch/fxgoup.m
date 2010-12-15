function fxgoup(currentfileName)
%FXGOUP  Go one level up and open fxdownloads index page.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula

newfilePath = fileparts(currentfileName);
for counter = 1:3
    newfilePath = fileparts(newfilePath);
    indexFilename = dir(fullfile(newfilePath,'downloads_index.html'));
    if ~isempty(indexFilename)
        web(fullfile(newfilePath,indexFilename.name));
        break;
    end
end
