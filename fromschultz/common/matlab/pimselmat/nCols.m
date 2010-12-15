function n = nCols(array)
% nCols - returns the number of columns in the input matrix
%
% INPUTS:
% array - matrix
%
% OUTPUTS:
% n - scalar number of columns in array
%
% EXAMPLE:
% a=magic(4);
% nCols(a)

% AUTHOR: Ken Hrovat
% $Id: nCols.m 4160 2009-12-11 19:10:14Z khrovat $

[m, n] = size(array);