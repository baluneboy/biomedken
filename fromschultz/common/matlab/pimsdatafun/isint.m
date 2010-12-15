function bln = isint(m,thresh)

% ISINT boolean matrix same size as m input with 1's where elements are "within thresh of being
% an integer" -- a new mathematical concept hereby dubbed a number's "hrovaticity"
%
% bln = isint(m,thresh);
%
% INPUTS:
% m - matrix (or vector or scalar) of values to test for hrovaticity
% thresh - scalar threshold to allow for some slop in the division calc
%
% OUTPUTS:
% bln - matrix same size as input with ones where there's an integer and
%       zeros elsewhere (NaNs do the expected thing)
%
% EXAMPLES:
% m = repmat(magic(3),2,1);
% m(8) = m(8)+1e-5; % altered hrovaticity
% blnLoose = isint(m,2e-6) % allow some slop
% blnStrict = isint(m) % no slop allowed

% Author: Ken Hrovat
% $Id: isint.m 6392 2010-12-09 13:33:47Z khrovat $

% Check for reals
if ~isreal(m)
    error('ISINT expects real inputs')
end

% Set threshold for "integerness" (this is a word, don't look it up)
if nargin == 1
    thresh = 0;
elseif nargin > 2
    error('need 1 or 2 input args')
end

% Elementwise division of nearest integer to m divided by m
b = fix(m)./m;

% Check ratio found in b to thresh to get boolean matrix
bln = (b >= 1-thresh & b <= 1+thresh);