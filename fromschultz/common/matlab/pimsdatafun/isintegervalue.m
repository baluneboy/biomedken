function blnIsInteger = isintegervalue( x )
% ISINTEGERVALUE test scalar, vector or matrix for "all integers"
% x can be a number , a vector or a matrix
% If blnIsInteger = 1, all elements in x are integers
% If blnIsInteger = 0, at least one element in x is not integer
% This function is written by Lowell Guangdi 2009/6/8
% Improved by the idea of Jan Simon, then tweaked by Ken Hrovat.
%
% See isinteger
%
% EXAMPLES
% isintegervalue([ 1 2 3 ])
% isintegervalue([ 1.23 4 ])
% isintegervalue('string')
% isintegervalue(pi)
% isintegervalue(3)

if ~isnumeric(x)
    blnIsInteger = 0;
else
    blnIsInteger = isequal( x, round( x ));
end