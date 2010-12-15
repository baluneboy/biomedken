function result = iseven(i)
% ISEVEN returns 1 if input is even; otherwise 0
%
% INPUTS:
% i - scalar value of integer
%
% OUTPUTS:
% result - boolean is 1 if input, i, is even; otherwise result is 0
%
% EXAMPLE:
% resultEven = iseven(2)
% resultOdd = iseven(1)
% resultError = iseven(1.5)

% AUTHOR: Ken Hrovat
% $Id: iseven.m 4160 2009-12-11 19:10:14Z khrovat $

if ( (nargin ~= 1) | (fix(i) ~= i) )
	help iseven
	error('MUST HAVE ONE INTEGER INPUT ARG')
end
result=~(rem(i,2));