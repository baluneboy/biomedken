function [strOut,strSubject,preSEscore,postSEscore,preWHscore,postWHscore,preCOORDscore,postCOORDscore] = getfuglmeyerprepostscores(strFile)

% getfuglmeyerprepostscores - get pre and post, SE & WH & COORD scores (ignores other scores in file)
%
% [strOut,strSubject,preSEscore,preWHscore,postSEscore,postWHscore] = getfuglmeyerprepostscores(strFile);
%
% INPUTS:
% strFile - string for complete path to file of interest
%
% OUTPUTS:
% strOut - string pretty print
% strSubject - string for strSubject
% preSEscore,preWHscore,postSEscore,postWHscore,preCOORDscore,postCOORDscore - scalar pre,post scores for SE,WH,COORD
%
% EXAMPLE
% strFile = 'S:\data\upper\clinical_measures\plas\s1332plas\Fugl-Meyer-s1332plas.xls';
% [strOut,strSubject,preSEscore,postSEscore,preWHscore,postWHscore,preCOORDscore,postCOORDscore] = getfuglmeyerprepostscores(strFile);

% Author: Ken Hrovat
% $Id: getfuglmeyerprepostscores.m 4160 2009-12-11 19:10:14Z khrovat $

% parse for strSubject
[strPath,strName] = fileparts(strFile);
pat = 'Fugl.Meyer.(?<strSubject>[cs]\d{4}\w{4})';
n = regexpi(strFile,pat,'names');
if isempty(n)
    strSubject = strFile;
else
    strSubject = n.strSubject;
end

% read cell NANSUM(D4:D27) for SE...
% ...pre (dc1)
preSEscore = nansum(xlsread(strFile,'DC 1','D4:D27'));

% ...post (dc3)
postSEscore = nansum(xlsread(strFile,'DC 3','D4:D27'));

% read cell NANSUM(D30:D43) for WH...
% ...pre (dc1)
preWHscore = nansum(xlsread(strFile,'DC 1','D30:D43'));

% ...post (dc3)
postWHscore = nansum(xlsread(strFile,'DC 3','D30:D43'));

% read cell NANSUM(D46:D48) for COORD...
% ...pre (dc1)
preCOORDscore = nansum(xlsread(strFile,'DC 1','D46:D48'));

% ...post (dc3)
postCOORDscore = nansum(xlsread(strFile,'DC 3','D46:D48'));

% nice string output
strOut = sprintf('%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f',strSubject,preSEscore,postSEscore,preWHscore,postWHscore,preCOORDscore,postCOORDscore);