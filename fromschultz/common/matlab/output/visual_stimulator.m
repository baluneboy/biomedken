function visual_stimulator(strSubject, strSession,strTask,strDir)
% VISUAL_STIMULATOR.m
% 
% Loads two images (one for rest condition, one move) and displays them
% alternately.  A .mat file is saved in pwd containing lagTime, a nx4
% matrix with the following columns:
% col1 = h.counter, the total number of images shown
% col2 = h.index, '1' and '2' referring to 'rest' and 'move' images
%   displayed, respectively
% col3 = time_elapsed, the time (in msec) from when the program was started 
%   to the time the image is displayed
% col4 = timeElapsedForOneTrial, the time between the keyboard press to
%   when the image is displayed (including the one second pause)
% 
% INPUTS:
% strTask - string for which task
% strDir - string for path to image directory (default is pwd)
% strSubject - string containing subject code  
% 
% EXAMPLE
%
% strDir = 'C:\wristViconPresentationImages\';';
% strTask = 'wrist_deviation';
% strSubject = 's1358plas';
% strSession = 'pre';
% visual_stimulator(strSubject,strSession,strTask) OR
% visual_stimulator(strSubject,strSession,strTask,strDir)

% Author: Krisanne Litinas, Ken Hrovat
% $Id: visual_stimulator.m 6391 2010-12-08 20:46:04Z klitinas $

% Get dir of images
if nargin == 3
    strDir = 'C:\wristViconPresentationImages';
end

% Create figure that shows images and handles keyboard inputs

hFig = figure('KeyReleaseFcn',@keyhandler);
% hFig = figure('KeyPressFcn',@keyhandler);

% Establish images and [preload?] set user data with images
locLoadImages(strTask, strDir,hFig, strSubject,strSession);

% -----------------------------------------
function locLoadImages(strTask,strDir,hFig, strSubject,strSession)
strPattern = ['^(?<num>\d{1,3})_' strTask '.*\.jpg$'];
cas = getverifyfiles(strPattern,strDir,'cas',4);
% cas = getverifyfiles(strPattern,strDir,'cas',2);
for i = 1:length(cas)
    strFile = cas{i};
    %   m(:,:,:,i) = imread(strFile);
    m{:,:,:,i} = imread(strFile);   % make m a cell to accomodate different image sizes.
end
% Test for equal dimensions of two images, if not equal than resize one
% (rest image) according to the other (task image).
if isequal(size(m{1}), size(m{2}), size(m{3}), size(m{4}))
else
    sizeM1 = size(m{1});
    newSize = sizeM1(1:2);
    m{2} = imresize(m{2}, newSize);
    m{3} = imresize(m{3}, newSize);
    m{4} = imresize(m{4}, newSize);
end
m = cell2mat(m);
% h.casFiles = cas;
% h.strDir = strDir;
% h.hFig = hFig;
h.task = strTask;
h.subject = strSubject;
h.session = strSession;
h.m = m;
h.counter = 1;
h.index = 1;
h.lagTime = [];
h.startTime = clock;

guidata(hFig,h)


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
oneTrialLagStartTime = clock;
pause(1);
imshow(h.m(:,:,:,h.index), 'InitialMagnification', 'fit');
% imshow(h.m(:,:,:,h.index));
timeElapsedForOneTrial = (etime(clock, oneTrialLagStartTime)) * 1000;
time_elapsed = (etime(clock, h.startTime)) * 1000; % time elapsed in msec
h.lagTime(h.counter,:) = [h.counter h.index time_elapsed timeElapsedForOneTrial];
% matPath = ['/home/tomato/eeg_emg_vicon/' h.subject '/' h.session '/'];
% matPath = fullfile('/home/tomato/eeg_emg_vicon', h.subject, h.session);
matPath = fullfile('c:/eeg_emg_vicon',h.subject,h.session);
if ~exist(matPath,'dir')
    mkdir(matPath)
end
matFile = [h.subject '_' h.task '_time_delay.mat'];
matFilename = fullfile(matPath, matFile);
lagTime = h.lagTime;
save(matFilename, 'lagTime')


fprintf('before increment:  counter = %d, index = %d \n',h.counter, h.index)
h.counter = h.counter + 1;

h.index = h.index + 1;
if h.index == 5
    h.index = 1;
end
% h.index = abs(rem(h.counter,2)-1)+1;
guidata(hFig,h);
fprintf('after increment:  counter = %d, index = %d \n',h.counter, h.index)


             