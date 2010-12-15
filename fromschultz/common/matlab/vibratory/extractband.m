function [subpxx, subf] = extractband(pxx,f,lower,upper)
% EXTRACTBAND - Extract band of frequencies and the corresponding PSD values
%               from "lower" frequency bound to "upper" frequency bound
%
% [subpxx, subf] = extractband(pxx,f,lower,upper)
%
%   Inputs: pxx vector of PSD values;
%           f vector corresponding to PSD values;
%           lower scalar for lower frequency bound;
%           upper scalar for upper frequency bound
%
%   Outputs: subpxx vector subset of pxx for desired frequency band
%            subf vector frequency band subset

% written by:  Ken Hrovat on 6/23/95
% $Id: extractband.m 4160 2009-12-11 19:10:14Z khrovat $

%% Check number of input/output arguments:

if ( ( nargin ~= 4 ) | ( nargout ~= 2) )
  error(sprintf('\nEXTRACTBAND: requires 4 input and 2 output arguments'))
end

%% Verify boundary conditions

if ( ( lower < min(f) ) | ( upper > max(f) ) )
  error(sprintf('\nEXTRACTBAND: desired band is not complete subset of f'))
end

ind = find( f >= lower & f <= upper );

% modification here?
if isempty(ind)
   subpxx=[NaN NaN];
   subf=[lower upper];
else
   subpxx = pxx(ind);
   subf = f(ind);
end