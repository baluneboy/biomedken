function [strOut,strSubject,preTimeTotal,postTimeTotal,preTimeSE,postTimeSE,preTimeWH,postTimeWH] = getamatpreposttotaltime(strFile)

% getamatpreposttotaltime - get AMAT pre and post total times (ignores other scores in AMAT file)
%
% [strOut,strSubject,preTimeTotal,postTimeTotal,preTimeSE,postTimeSE,preTimeWH,postTimeWH] = getamatpreposttotaltime(strFile);
%
% INPUTS:
% strFile - string for complete path to file (AMAT file) of interest
%
% OUTPUTS:
% strOut - string for pretty print
% strSubject - string for strSubject
% preTimeTotal - scalar dc1 score
% postTimeTotal - scalar dc3 score
% preTimeSE - scalar dc1 score for SE
% postTimeSE - scalar dc3 score for SE
% preTimeWH - scalar dc1 score for WH
% postTimeWH - scalar dc3 score for WH
%
% EXAMPLE
% strFile = 'S:\data\upper\clinical_measures\plas\s1601hand\AMAT-s1601hand.xls';
% [strOut,strSubject,preTimeTotal,postTimeTotal,preTimeSE,postTimeSE,preTimeWH,postTimeWH] = getamatpreposttotaltime(strFile); disp(strOut)

% Author: Ken Hrovat
% $Id: getamatpreposttotaltime.m 4160 2009-12-11 19:10:14Z khrovat $

% parse for strSubject
[strPath,strName] = fileparts(strFile);
pat = 'AMAT.(?<strSubject>.\d{4}\w{4})';
n = regexpi(strFile,pat,'names');
if isempty(n)
    strSubject = strFile;
else
    strSubject = n.strSubject;
end

% read cell B78 for totalTime...
% ...pre (dc1)
preTimeTotal = xlsread(strFile,'dc1','b78');

% ...post (dc3)
postTimeTotal = xlsread(strFile,'dc3','b78');

% read cell B76 for totalTime...
% ...pre (dc1)
preTimeSE = xlsread(strFile,'dc1','b76');

% ...post (dc3)
postTimeSE = xlsread(strFile,'dc3','b76');

% read cell C77 for totalTime...
% ...pre (dc1)
preTimeWH = xlsread(strFile,'dc1','c77');

% ...post (dc3)
postTimeWH = xlsread(strFile,'dc3','c77');

% nice string output
strOut = sprintf('%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f',strSubject,preTimeTotal,postTimeTotal,preTimeSE,postTimeSE,preTimeWH,postTimeWH);