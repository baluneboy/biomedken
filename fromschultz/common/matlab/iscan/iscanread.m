function cRunInfoTable = iscanread(strFile)

% ISCANREAD - a function to read the output ascii file from ISCAN
%
% %INPUTS
% strFile = ISCAN ascii raw output i.e.
% S:\data\lower\vicon_iscan\c9998cogp\20090804\batch_01.tda
%
% %OUTPUTS
% cRunInfoTable - 1xR cell array of iscan run info; where each element of cell array is a struct like this
% where R = number of runs
% .data - MxN matrix of iscan measurements where M is number of samples and
% N is a 16 column array of columns with the following headers:
% 1 = sample number
% 2 = raw pupil 1 horizontal position
% 3 = raw pupil 1 vertical position
% 4 = raw pupil 2 horizontal position
% 5 = raw pupil 2 vertical position
% 6 = point of regard (POR) for horiz. position source A
% 7 = POR for vert. position source A
% 8 = POR for horiz. position source A (raw)
% 9 = POR for vert. position source A (raw)
% 10 = POR for horiz. position source B
% 11 = POR for vert. position source B
% 12 = eye 1 azimuth angle
% 13 = eye 1 elevation angle
% 14 = eye 2 azimuth angle
% 15 = eye 2 elevation angle
% 16 = digital input 1A
%
% %EXAMPLE
% strFile = 'S:\backups\keirn\iscan\20090715\batch_01_5trials.tda';
% cRunInfoTable = iscanread(strFile);

% Author: Ken Hrovat
% $Id: iscanread.m 4160 2009-12-11 19:10:14Z khrovat $

% Establish needed regular expressions
strPatternRunInfoTable = '(?<run>\d+)\s+(?<date>\d{4}/\d{2}/\d{2})\s+(?<starttime>\d{2}:\d{2}:\d{2})\s+(?<samples>\d+)\s+(?<fs>\d+)\s+(?<runsecs>\d+.\d+)\s+(?<imagefile>\w+.\w+)\s+(?<description>.*)';
strPatternRunLineNums = ':(?<linenum>\d+): Sample';

% Call perl parse script to get "DATA SUMMARY TABLE" line number
strLine = perl('iscanparsedatasummarytableline.pl',strFile);

% Read file through the line found above
[str,foo] = perl('printrangelines.pl','1',strLine,strFile);
casLines = strsplit(char(10),str);
cRunInfoTable = regexp(casLines,strPatternRunInfoTable,'names');
cRunInfoTable(findemptycells(cRunInfoTable)) = [];

% Grep for "Sample #" lines
strCmd = ['grep(''-n'',''-u'',''Sample #'',''' strFile ''');'];
[str,foo] = evalc(strCmd);
casSamps = strsplit(char(10),str);
cRunLines = regexp(casSamps,strPatternRunLineNums,'names');
cRunLines(findemptycells(cRunLines)) = [];

% Error check
if numel(cRunInfoTable) ~= numel(cRunLines)
    error('daly:iscan:troubleReadingTDAfile','mismatch between run info table (%d runs) and grep found (%d runs) in %s',numel(cRunInfoTable),numel(cRunLines))
end

% Gather line numbers for each run & read data for each
for i = 1:numel(cRunLines)
    cRunInfoTable{i}.run = str2num(cRunInfoTable{i}.run);
    cRunInfoTable{i}.runsecs = str2num(cRunInfoTable{i}.runsecs);
    cRunInfoTable{i}.fs = str2num(cRunInfoTable{i}.fs);
    cRunInfoTable{i}.firstLine = str2double(cRunLines{i}.linenum) + 1;
    cRunInfoTable{i}.samples = str2double(cRunInfoTable{i}.samples);
    cRunInfoTable{i}.lastLine = cRunInfoTable{i}.firstLine + cRunInfoTable{i}.samples - 1;
    fprintf('\nReading %6d samples for %4.2fs run #%3d...',cRunInfoTable{i}.samples,cRunInfoTable{i}.runsecs,cRunInfoTable{i}.run)
    data = locGetData(i,cRunInfoTable,strFile);
    cRunInfoTable{i}.data = reshape(data,16,cRunInfoTable{i}.samples)';
    fprintf('done.')
end
fprintf('\n')

% -------------------------------------------------
function data = locGetData(i,cRunInfoTable,strFile)
fid = fopen(strFile,'r');
c = textscan(fid,'%f',cRunInfoTable{i}.samples*16,'headerlines',cRunInfoTable{i}.firstLine-1);
fclose(fid);
data = c{1};