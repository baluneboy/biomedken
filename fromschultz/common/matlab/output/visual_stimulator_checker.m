function T = visual_stimulator_checker(strTask,strDir)

% INPUTS:
% strTask - string for which task
% strDir - string for path to image directory (default is pwd)
%
% EXAMPLE
%
% strTask = 'wrist_ext_only';
% strDir = 'c:\temp\example_dir\';
% T = visual_stimulator_checker(strTask,strDir);

% Author: Ken Hrovat
% $Id: visual_stimulator_checker.m 4160 2009-12-11 19:10:14Z khrovat $


% Create figure that shows images and handles keyboard inputs
hFig = figure('KeyReleaseFcn',@keyhandler);

% Establish images and [preload?] set user data with images
locLoadImages(strTask, strDir,hFig);

h = guidata(hFig);
% Loop to get nominal pause-to-imshown duration
T = [];
for i = 1:1000
    h.counter = h.counter + 1;
    h.index = abs(rem(h.counter,2)-1)+1;
    guidata(hFig, h);
    t = locPauseAndShow(hFig);
    T = [T t];
end

% -----------------------------------------
function locLoadImages(strTask,strDir,hFig)
strPattern = ['^(?<num>\d{1,3})_' strTask '.*\.jpg$'];
cas = getverifyfiles(strPattern,strDir,'cas',2);
for i = 1:length(cas)
    strFile = cas{i};
    %   m(:,:,:,i) = imread(strFile);
    m{:,:,:,i} = imread(strFile);   % make m a cell to accomodate different image sizes.
end
% Test for equal dimensions of two images, if not equal than resize one
% (rest image) according to the other (task image).
if isequal(size(m{1}), size(m{2}))
else
    sizeM1 = size(m{1});
    newSize = sizeM1(1:2);
    m{2} = imresize(m{2}, newSize);
end
m = cell2mat(m);
% h.casFiles = cas;
% h.strDir = strDir;
% h.hFig = hFig;
h.task = strTask;
h.m = m;
h.counter = 1;
h.index = 1;
h.lagTime = [];
h.startTime = clock;

guidata(hFig,h)

% --------------------------
function t = locPauseAndShow(hFig)
h = guidata(gcf);  % retrieve previously-stored data...
if 32 == 32 % spacebar to next image
    pause(1);
    tzero = clock;
    imshow(h.m(:,:,:,h.index));
    t = (etime(clock, tzero)) * 1000; % time elapsed in msec
end

fprintf('before increment:  counter = %d, index = %d \n',h.counter, h.index)

% guidata(hFig,h);
fprintf('after increment:  counter = %d, index = %d \n',h.counter, h.index)

% --------------------------
function keyhandler(src,evt)
h = guidata(gcbf);  % retrieve previously-stored data...
if abs(evt.Character) == 32 % spacebar to next image
    locShowImage(gcbf,h)
else
    % Placeholder to move to next task
    % locResetDialog(gcbf,h)
    %fprintf('WTF is %d for?\n',abs(evt.Character))
end

% -----------------------------
function locResetDialog(hFig,h)
[h.i,v] = listdlg('PromptString','Select file for next image:',...
    'SelectionMode','single',...
    'ListString',h.casFiles);
guidata(hFig,h);

% ---------------------------
function locShowImage(hFig,h)
pause(1);

% imshow(h.m(:,:,:,h.index), 'InitialMagnification', 'fit');
imshow(h.m(:,:,:,h.index));
time_elapsed = (etime(clock, h.startTime)) * 1000; % time elapsed in msec
h.lagTime(h.counter,:) = [h.counter h.index time_elapsed];
matFilename = [h.task '_time_delay.mat'];
lagTime = h.lagTime;
save(matFilename, 'lagTime')


fprintf('before increment:  counter = %d, index = %d \n',h.counter, h.index)
h.counter = h.counter + 1;
h.index = abs(rem(h.counter,2)-1)+1;
guidata(hFig,h);
fprintf('after increment:  counter = %d, index = %d \n',h.counter, h.index)


