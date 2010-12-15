function [strSubject,preScore,postScore,strOut] = getmodifiedashworthprepostscores(strFile)

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
% $Id: assessgetmodifiedashworthprepostscores.m 4160 2009-12-11 19:10:14Z khrovat $

%sprintf('%s',strFile)
% parse for strSubject
[strPath,strName] = fileparts(strFile);
pat = 'Modified.Ashworth-(?<strSubject>.\d{4}\w{4})';
n = regexpi(strName,pat,'names');
if isempty(n)
    strSubject = strFile;
else
    strSubject = n.strSubject;
end

% read cell B14
% ...pre (dc1)
preScore = xlsread(strFile,'dc1','E14'); % SOMETIMES B14 OR E14?

%sprintf('Pre, E14: %0.3f',preScore)
otherScore = xlsread(strFile,'dc1','B14');
%sprintf('Pre, B14: %0.3f',otherScore)
% ...post (dc3)
postScore = xlsread(strFile,'dc3','E14'); % SOMETIMES B14 OR E14?
%sprintf('Post, E14: %0.3f',postScore)
thatoneScore = xlsread(strFile,'dc3','B14');
%sprintf('Post, B14: %0.3f',thatoneScore)
% nice string output
strOut=sprintf('%s, Pre E14: %.3f, B14: %.3f, Post E14: %.3f, B14: %.3f',strSubject,preScore, otherScore, postScore, thatoneScore);