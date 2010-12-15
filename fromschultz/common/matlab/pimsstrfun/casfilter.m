function casOut = casfilter(cas,casToMatch)

%CASFILTER filter cell array of strings depends on variable name of 2nd arg (casKeep or casSkip do opposite filt action)
%
% EXAMPLE
% cas = {'one','two/three','two/four/six','five/toot'};
% casKeep = {'two'};
% casKeepers = casfilter(cas,casKeep)
% casSkip = {'two'};
% casSkippers = casfilter(cas,casSkip)

% Author: Ken Hrovat
% $Id: casfilter.m 4160 2009-12-11 19:10:14Z khrovat $

% disp(inputname(2))
strWhich = inputname(2);
if ~strcmp(strWhich,'casKeep') && ~strcmp(strWhich,'casSkip')
    error('unknownInput:unmatchedName', ... 
      '2nd input, "%s" does not match casKeep or casSkip.',strWhich);
end

iMatch = [];
for i = 1:length(casToMatch)
    pat = ['\w*' casToMatch{i} '\w*'];
    m = regexpi(cas,pat,'match'); % find matches
    ind = find(~cellfun('isempty', m));
    iMatch = [iMatch; ind(:)];
end
iMatch = unique(iMatch);
if strcmp(strWhich,'casKeep')
    if isempty(iMatch)
        casOut = {};
    else
        casOut = cas(iMatch);
    end
else
    casOut = cas;
    if isempty(iMatch)
        return
    end
    casOut(iMatch) = [];
end