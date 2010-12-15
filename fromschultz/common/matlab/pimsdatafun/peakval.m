function y = peakval(x)
% PEAKVAL compute extreme value, either min or max, whichever has greater abs value
%
% INPUTS:
% x - vector of data
%
% OUTPUTS:
% y - scalar peakval of x

% AUTHOR: Ken Hrovat
% $Id: peakval.m 4160 2009-12-11 19:10:14Z khrovat $

[m,i] = max(abs(x));
y = x(i);