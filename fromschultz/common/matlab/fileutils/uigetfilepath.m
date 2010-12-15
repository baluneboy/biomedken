function [strFile,strPath] = uigetfilepath(strWild,strPrompt);
if nargin==1
    strPrompt = 'Select files';
end
strFile = uipickfiles('filterspec',strWild,'output','char','prompt',strPrompt,'num',1);
strPath = fileparts(strFile);