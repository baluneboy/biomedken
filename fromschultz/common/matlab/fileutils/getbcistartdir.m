function strDir = getbcistartdir(strEnv)

%GETBCISTARTDIR Return string for valid starting BCI directory.
% For dat file browsing, this returns a string for bci directory based on
% environment variable string input if that is a valid dir; otherwise pwd.
%
% INPUTS:
% strEnv - string for environment variable (defaults to 'BCI')
%
% OUTPUTS:
% strDir - string for valid dir to start browsing from (for dat files)
%
% EXAMPLE:
% strDir = getbcistartdir('thisEnvVarProbablyDoesNotExist')
% strDir = getbcistartdir('bci')

% Author: Ken Hrovat
% $Id: getbcistartdir.m 4160 2009-12-11 19:10:14Z khrovat $

% check input
if nargin == 0
    strEnv = 'BCI';
end

% get env. variable
strDir = getenv(strEnv);
if isempty(strDir) % no env. var., so bail out with pwd
    strDir = pwd;
    return
end

% check/coerce valid directory
if ~exist(strDir,'dir')
    strDir = pwd; % non-exist dir, so bail out with pwd
end
    