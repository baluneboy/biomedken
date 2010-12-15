function m = nRows(array)
% nRows - returns the number of rows in the input matrix
%
% INPUTS:
% array - matrix
%
% OUTPUTS:
% n - scalar number of rows in array
%
% EXAMPLE:
% a=magic(4);
% nRows(a)

% AUTHOR: Ken Hrovat
% $Id: nRows.m 4160 2009-12-11 19:10:14Z khrovat $

[m, n] = size(array);