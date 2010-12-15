function [a,b] = code_style_standards(x,y,v)

%CODE_STYLE_STANDARDS Short sentence to describe function goes here.
%   [a,b] = code_style_standards(x,y,v) finds mean values of the inputs
%   such that a is mean of x and y and b is mean of the elements of v.
%
% INPUTS:
% x - scalar double for x-axis component
% y - scalar double for y-axis component
% v - vector of doubles for something else to look at
%
% OUTPUTS:
% a - scalar value for mean of x & y
% b - scalar value for mean of elements of input vector, v
%
% CLASS SUPPORT: [ include notes if user can trip on in/out class types ]
% x, y must be scalar double type (class), v must be vector of doubles
% a has same class (type) as x, b has same type as v
%
% See also isscalar, isvector, isa, getbcistartdir, notlinked.
%
% EXAMPLES: [ convenient as last in help text for "help function_name"  ]
% [a,b] = code_style_standards(1,2,[3 4]) % legitimate example here
% code_style_standards; % no arguments, show some helpful text

% Author: Ken Hrovat
% $Id: code_style_standards.m 4120 2009-12-07 19:51:04Z khrovat $

% Show some helpful text when no input arguments are given
if nargin == 0
    fprintf('\nThe "H1" header line convention facilitates a built-in MATLAB')
    fprintf(' utility to generate Contents.m files automagically.')
    fprintf('\nThe "See also" line automagically gets hyperlinked to')
    fprintf(' "help function_name" in command window (if on path).')
    fprintf('\nAlso, it is helpful to prefix variables with:')
    fprintf('\n "str" for string')
    fprintf('\n "s" for structure')
    fprintf('\n "cas" for cell array of strings')    
    fprintf('\n\n')
    return
end

% Check inputs
blnIsScalarDouble = locAreScalarDoubles(x,y);
if ~blnIsScalarDouble
    %warning('daly:project:camelCaseWarnBlurb','This string gives more detail on the warning thrown in "%s".',mfilename)
    %error('daly:project:camelCaseErrorBlurb','This string gives more detail on the error thrown in "%s".',mfilename);
    error('daly:project:badInput','The first 2 inputs were not detected as scalar doubles in "%s".',mfilename);
end
blnIsVectorDouble = locIsVectorDouble(v);
if ~blnIsVectorDouble
    error('daly:project:badInput','The 3rd input was not detected as vector of doubles in "%s".',mfilename);
end

% Compute mean of first 2 inputs
a = mean([x y]);

% Compute mean of 3rd, vector, input
b = mean(v);


% ---- Local functions get "loc" prefix --------------
function blnIsScalarDoubles = locAreScalarDoubles(x,y)
blnIsScalarDoubles = 0;
if isa([x y],'double') && all(cellfun(@isscalar,{x,y}))
    blnIsScalarDoubles = 1;
end

% -----------------------------------------------
function blnIsVectorDouble = locIsVectorDouble(v)
blnIsVectorDouble = 0;
if isa(v,'double') && isvector(v)
    blnIsVectorDouble = 1;
end