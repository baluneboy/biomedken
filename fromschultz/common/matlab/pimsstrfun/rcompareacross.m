function blnAcross = rcompareacross(cas)

% RCOMPAREACROSS [obsolete, see casdiff] recursive difference comparison across cell array of strings
%   return the following for comparison:
%    - the first element is always one
%    - the second element is zero if cas{2} is equal to cas{1}; otherwise it's one
%    - the third element is zero if cas{3} is equal to cas{2}; otherwise it's one
%    - and so on
%
% SYNTAX:
% blnAcross = rcompareacross(cas);
%
% INPUTS:
% cas - cell array of strings in "vector" shape and having at least 2 elements
%
% OUTPUTS:
% blnAcross - row vector of boolean flags as described above
%
% EXAMPLES
% cas = {'stringA', 'stringA', 'stringC', 'stringA'}'
% blnAcross1 = rcompareacross(cas)
%
% cas = {'stringA', 'mitten', 'santa','santa','reindeer'}
% blnAcross2 = rcompareacross(cas)
%
% cas = {'stringA', 'stringA', 'stringC', '#cake'}
% blnAcross3 = rcompareacross(cas)
%
% cas = {'stringA', 'stringA', 'stringC', '~!@#$%^&*'} % NO ERROR HERE!
% blnAcross4 = rcompareacross(cas)

% Author: Ken Hrovat (with recursion inadvertently suggested by Krisanne Litinas)
% $Id: rcompareacross.m 4160 2009-12-11 19:10:14Z khrovat $
%
% If I had to do this over, then I'd probably call this function something
% like diffcasrec.m for "diff on cas recursively".

% Check input shape & count
if ~isvector(cas) || numel(cas) < 2
    error('daly:bci:rcompareacross:badInput','cas input must have at least 2 elements in "vector" form')
end

% Use recursion to drill down efficiently (always use caution with recursion)
blnAcross = [1 locRecursiveCompare(cas)];

% -------------------------------------
function bln = locRecursiveCompare(cas)
% this is recursion suggested by Krisanne Litinas' e-mail
if numel(cas) == 2
    bln = ~strcmp(cas{1},cas{2});
else
    bln = [~strcmp(cas{1},cas{2}) locRecursiveCompare(cas(2:end))];
end