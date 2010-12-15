function [status,result] = dirod(strDir,strLabel)

%
% EXAMPLE
% strDir = pwd
% strLabel = 'justTesting';
% [status,result] = dirod(strDir,strLabel); status
% [status,result] = dirod(strDir); status

if nargin == 1
    strLabel = '';
elseif nargin ~= 2 
    error('wrong number of input args')
end
strOut = fullfile(strDir,['dirod_' strLabel '_' datestr(now,30) '.txt']);

if isunix
    strCmd = ['ls -lrt ' strDir ' > ' strOut];
else
    strCmd = ['dir /od /tw ' strDir ' > ' strOut];
end
[status,result] = unix(strCmd);