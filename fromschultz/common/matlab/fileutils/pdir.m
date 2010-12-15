function strParentDir = pdir(strChildDir)

% return string that is parent dir of either pwd when no arg or of
% child input dir arg
%
% strParentDir = pdir(strChildDir);
%
% INPUTS:
% strChildDir (optional) - string for child dir (pwd if no input arg)
%
% OUTPUTS:
% strParentDir - string for parent dir
%
% EXAMPLE
% fprintf('\n\nThe parent dir of...\n%s\nis...\n%s\n\n',pwd,pdir)

% author: Ken Hrovat
% $Id: pdir.m 4160 2009-12-11 19:10:14Z khrovat $

if nargin == 0
    strChildDir = pwd;
end
if ~exist(strChildDir,'dir')
    error('daly:common:fileNotFound','directory "%s" does not exist',strChildDir)
end
strParentDir = fileparts(strChildDir);