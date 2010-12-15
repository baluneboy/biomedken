function showrun(strFile,run)

% %EXAMPLE
% strFile = 'S:\backups\keirn\iscan\20090715\batch_01_5trials.tda';
% run = 3;
% showrun(strFile,run)

% Author: Ken Hrovat
% $Id: showrun.m 4160 2009-12-11 19:10:14Z khrovat $

% Read all data
cRunInfoTable = iscanread(strFile);

% Now just show data for desired run
data = cRunInfoTable{run}.data;
fs = cRunInfoTable{run}.fs;
pupilH1 = data(:,2);
pupilV1 = data(:,3);
t = gent(pupilH1,fs);
plot(t,pupilH1,t,pupilV1,'r');