function [strOut,strSubject,preSEscore,postSEscore,preWHscore,postWHscore] = getmmtprepostscores(strFile)

% getmmtprepostscores - get pre and post, SE & WH scores (ignores other scores in file)
%
% [strOut,strSubject,preSEscore,preWHscore,postSEscore,postWHscore] = getmmtprepostscores(strFile);
%
% INPUTS:
% strFile - string for complete path to file of interest
%
% OUTPUTS:
% strOut - string pretty print
% strSubject - string for strSubject
% preSEscore,preWHscore,postSEscore,postWHscore - scalar pre,post sum scores for SE,WH
%
% EXAMPLE
% strFile = 'S:\data\upper\clinical_measures\plas\s1332plas\MMT-s1332plas.xls';
% [strOut,strSubject,preSEscore,preWHscore,postSEscore,postWHscore] = getmmtprepostscores(strFile);

% Author: Ken Hrovat
% $Id: getmmtprepostscores.m 4160 2009-12-11 19:10:14Z khrovat $

% parse for strSubject
[strPath,strName] = fileparts(strFile);
pat = 'MMT.(?<strSubject>[cs]\d{4}\w{4})';
n = regexpi(strFile,pat,'names');
if isempty(n)
    strSubject = strFile;
else
    strSubject = n.strSubject;
end

% read cell mean(B10:B16,B18:B21) for SE...
% ...pre (dc1)
preSEscore = nansum(xlsread(strFile,'dc1','B10:B21'));

% ...post (dc3)
postSEscore = nansum(xlsread(strFile,'dc3','B10:B21'));

% read cell mean(B23:B24,B26:B31) for WH...
% ...pre (dc1)
preWHscore = nansum(xlsread(strFile,'dc1','B23:B31'));

% ...post (dc3)
postWHscore = nansum(xlsread(strFile,'dc3','B23:B31'));

% nice string output
strOut = sprintf('%s,%.3f,%.3f,%.3f,%.3f',strSubject,preSEscore,postSEscore,preWHscore,postWHscore);