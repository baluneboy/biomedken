function [strOut,strSubject,preScore,postScore] = getmodifiedashworthprepostscores(strFile)

% getmodifiedashworthprepostscores - get pre and post scores
%
% [strOut,strSubject,preScore,postScore] = getmodifiedashworthprepostscores(strFile);
%
% INPUTS:
% strFile - string for complete path to file of interest
%
% OUTPUTS:
% strOut - string pretty print
% strSubject - string for strSubject
% preScore,postScore - scalar pre,post scores
%
% EXAMPLE
% strFile = 'S:\data\upper\clinical_measures\plas\s1332plas\Modified-Ashworth-s1332plas.xls';
% [strOut,strSubject,preScore,postScore] = getmodifiedashworthprepostscores(strFile);

% Author: Ken Hrovat
% $Id: getmodifiedashworthprepostscores.m 4160 2009-12-11 19:10:14Z khrovat $

% parse for strSubject
[strPath,strName] = fileparts(strFile);
pat = 'Modified.Ashworth.(?<strSubject>[cs]\d{4}\w{4})'; %changed dash in string to . and removed .xls from end -MC Aug 08
n = regexpi(strName,pat,'names');
if isempty(n)
    strSubject = strFile;
else
    strSubject = n.strSubject;
end

% read cell B14
% ...pre (dc1)
preScore = xlsread(strFile,'dc1','E14'); % SOMETIMES B14 OR E14?
% ...post (dc3)
postScore = xlsread(strFile,'dc3','E14'); % SOMETIMES B14 OR E14?

% nice string output
strOut = sprintf('%s,%.3f,%.3f',strSubject,preScore,postScore);