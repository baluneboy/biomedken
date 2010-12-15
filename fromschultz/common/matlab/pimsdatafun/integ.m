function y = integ(x,varargin)
% INTEG compute integrated value (2nd arg for sample rate; defaults to 200)
%
% INPUTS:
% x - vector of data
% fs - scalar sample rate (default is 200 sa/sec if not input)
%
% OUTPUTS:
% y - scalar integrated x

% AUTHOR: Ken Hrovat
% $Id: integ.m 4160 2009-12-11 19:10:14Z khrovat $

if nargin == 1
    fs = 200;
else
    fs = varargin{1};
end
dt = 1/fs;
y = sum(x*dt)