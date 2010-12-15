function s = parsesubjectcode(strSubject)
% parsesubjectcode.m - returns subject type [control/stroke/tbi], codenum,
% studyname given full subject code
%
% INPUTS
% strSubject - string, subject code like 's1361plas'
% 
% OUTPUTS
% s - structure with fields:
%     strClass - string, 
%           'n' for tbi, control phase
%           's' for stroke/tbi treatment
%           'c' for control
%     strNum - string, subject number
%     strStudy - string, study code [like 'tbis' for tbi study]
% 
% EXAMPLE
% strSubject = 'n1903tbis';
% s = parsesubjectcode(strSubject)

% Author - Krisanne Litinas
% $Id$

strSubjPattern = '(?<strClass>^[ncs])(?<num>\d{4})(?<strStudy>\w{4})';
s = regexp(strSubject,strSubjPattern,'names');