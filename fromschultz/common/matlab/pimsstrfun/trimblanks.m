function [out] = trimblanks(s)
%TRIMBLANKS remove leading blanks (see built-in DEBLANK too)
%
%   TRIMBLANK(S), when S is a cell array of strings, removes the same numberof leading blanks 
%  from each element of S, so that the longest string has no blanks in the beginning.
%
% i.e.
%    s ={'     one:'                   out = {'one:'
%        '     two:'         --->           '  two:'     
%        '   three:'}                       'three:'}
%
%    INPUT: Cell array of strings
%   OUTPUT: Cell array of strings  
%          [out] = trimblanks(S)        


%
% Author: Eric Kelly 6/20/2000
% $Id: trimblanks.m 4160 2009-12-11 19:10:14Z khrovat $
%


error(nargchk(1,1,nargin));

if ~iscell(s),
  error('S must be a cell array.');
end

% Create padded array of strings
temp=str2mat(s);

% Find all nonblanks
[r,c] = find(temp~=' ');

% Eliminate all leading columns containing only blanks
if min(c)>1
   temp(:,1:min(c)-1) = [];
end

% Convert out to cell array
out= cellstr(temp);

