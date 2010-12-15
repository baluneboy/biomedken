function blnAcross = casdiff(cas)

% CASDIFF compare across cell array of strings
%   return the following for comparison:
%    - the first element is always one
%    - the second element is zero if cas{2} is equal to cas{1}; otherwise it's one
%    - the third element is zero if cas{3} is equal to cas{2}; otherwise it's one
%    - and so on with as many output elements as input elements
%
% SYNTAX:
% blnAcross = casdiff(cas);
%
% INPUTS:
% cas - cell array of strings in "vector" shape and having at least 2 elements
%
% OUTPUTS:
% blnAcross - row vector of boolean flags as described above
%
% EXAMPLES
%
% cas = {'stringA', 'stringA', 'stringC', '~!@#$%^&*'}, casdiff(cas)
%
% casOriginal = {'a','b','c','c','d','e','e','e','f','f','g'};
% % A "shift" loop for more comprehensive and boundary testing
% for i = length(casOriginal):-1:1
%   cas = circshift(casOriginal',i)'; % circle shift by one element
%   blnAcross = casdiff(cas);
%   fprintf('\n%s\n  ',repmat('-',1,50))
%   fprintf('%s | ',cas{:})
%   fprintf('\n%d',blnAcross(1))
%   fprintf('   %d',blnAcross(2:end))
%   fprintf('\n')
% end

% Author: Ken Hrovat
% $Id: casdiff.m 4160 2009-12-11 19:10:14Z khrovat $

% Check input shape & count
if ~isvector(cas) || numel(cas) < 2
    error('daly:bci:casdiff:badInput','cas input must have at least 2 elements in "vector" form')
end

% Do string-by-string comparison; the not converts compare to diff logic
blnDiff = not(strcmp(cas(2:end),cas(1:end-1))); 

% Prepend automatic one and reshape output to row form
blnAcross = [1; blnDiff(:)]';