function [strOut,strSubject,preAthruDscore,postAthruDscore,preTotalScore,postTotalScore] = getfimpartialprepostscores(strFile)

% getfimpartialprepostscores - get pre and post, SE & WH scores (ignores other scores in file)
%
% [strOut,strSubject,preAthruDscore,postAthruDscore,preTotalScore,postTotalScore] = getfimpartialprepostscores(strFile);
%
% INPUTS:
% strFile - string for complete path to file of interest
%
% OUTPUTS:
% strOut - string pretty print
% strSubject - string for strSubject
% preAthruDscore,postAthruDscore,preTotalScore,postTotalScore - scalar pre,post scores
%
% EXAMPLE
% strFile = 'S:\data\upper\clinical_measures\plas\s1332plas\FIM-s1332plas.xls';
% [strOut,strSubject,preAthruDscore,postAthruDscore,preTotalScore,postTotalScore] = getfimpartialprepostscores(strFile);

% Author: Ken Hrovat
% $Id: getfimpartialprepostscores.m 4160 2009-12-11 19:10:14Z khrovat $

% parse for strSubject
[strPath,strName] = fileparts(strFile);
pat = 'FIM-(?<strSubject>.\d{4}\w{4}).xls';
n = regexpi(strFile,pat,'names');
if isempty(n)
    strSubject = strFile;
else
    strSubject = n.strSubject;
end

% read cell NANSUM(C4:C7) for AthruD...
% ...pre (dc1)
preAthruDscore = nansum(xlsread(strFile,'DC1','C4:C7'));
% ...post (dc3)
postAthruDscore = nansum(xlsread(strFile,'DC3','C4:C7'));

% read cell NANSUM(C4:C31) for Total...
% ...pre (dc1)
preTotalScore = nansum(xlsread(strFile,'DC1','C4:C31'));
% ...post (dc3)
postTotalScore = nansum(xlsread(strFile,'DC3','C4:C31'));

% nice string output
strOut = sprintf('%s,%.3f,%.3f,%.3f,%.3f',strSubject,preAthruDscore,postAthruDscore,preTotalScore,postTotalScore);