function fxselectdir
%FXSELECTDIR  Select a default download directory.
%
%   FXSELECTDIR Select a default download directory.
%
%   Example:
%     fxselectdir

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula

indexPath = '';
    rootPath = uigetdir(cd,'Select a folder');
    if rootPath == 0
        %exit if no directory is choosen
        return;
    end
    cd(rootPath);
    [dirpath filename ext] = fileparts(rootPath);
    if isempty(ext)
        %check if the directory choosen is fxdownloads. if fxdownloads direcoty
        %is choosen assign user selected directory as indexPath or else
        %create a fxdownloads directory and assign it indexPath
        if ~isempty(filename)
            if ~strcmp(filename,'fxdownloads')
                [subdirpath subfilename] = fileparts(dirpath);
                if strcmp(subfilename,'fxdownloads')
                    indexPath = rootPath;
                else
                    if ~isdir('fxdownloads')
                        [status, message, mesageid] = mkdir('fxdownloads');
                        if status == 0
                            errordlg([mesageid ': ' message],'Error');
                        end
                        indexPath = fullfile(rootPath,'fxdownloads');
                    else
                        indexPath = fullfile(rootPath,'fxdownloads');
                    end
                end
            else
                indexPath = rootPath;
            end
        else
            indexPath = fullfile(rootPath,'fxdownloads');
        end
    else
        errordlg('Invalid filname.', 'Error');
    end

    if ispref('fileexchange','prefindexPath')
        setpref('fileexchange','prefindexPath',indexPath);
    else
        addpref('fileexchange','prefindexPath',indexPath);
    end

