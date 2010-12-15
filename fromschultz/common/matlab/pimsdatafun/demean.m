function yy = demean(y)
% demean.m - subtracts mean of vector to produce same vector with zero-mean
%            or, if input is a matrix, then do this on a column-wise basis
% 
% INPUTS
% y - column vector (or matrix)
% 
% OUTPUTS
% yy - y with zero-mean (or zero column means)
% 
% EXAMPLE
% y = [4 4 5 5 4 4 3 3];
% yy = demean(y)
%
% m = magic(3)
% mm = demean(m)

% Author - Krisanne Litinas
% $Id: demean.m 4160 2009-12-11 19:10:14Z khrovat $

%m = mean(y);
m = repmat(mean(y),size(y,1),1);
yy = y - m;