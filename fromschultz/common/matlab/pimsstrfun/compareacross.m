function blnAcross = compareacross(cas)

% COMPAREACROSS [obsolete, see casdiff]
%
% EXAMPLES
% cas = {'stringA', 'stringA', 'stringC', 'stringA'};
% blnAcross1 = compareacross(cas)
%
% cas = {'stringA', 'mitten', 'santa','santa','reindeer'};
% blnAcross2 = compareacross(cas)
%
% cas = {'stringA', 'stringA', 'stringC', '#cake'};
% blnAcross3 = compareacross(cas)
%
% cas = {'stringA', 'stringA', 'stringC', '~!@#$%^&*'}; % get error here
% blnAcross4 = compareacross(cas)

% Verify we have a "vector" cas (one of dimensions is one)
if min(size(cas)) ~= 1
    error('daly:bci:compareacross:badInput','one of cas input dims must equal one')
end

% Coerce input to columnwise orientation
if size(cas,1) == 1
    cas = cas';
end

% Need to have same-length strings in each cell for downstream comparison
c = abs(char(cas));
r = locGetUnusedReplacementForSpace(char(cas));
c(find(c(:)==32)) = r; % replace spaces(=32) from padding with unused value & not simply "at"(=64)
cas = cellstr(char(c));

% Let's make numbers out of these strings
m = abs(cell2mat(cas));

% Now the crux of this routine is a diff, but we toss sign via abs
d = abs(diff(m));

% Condense results into one dimension via sum & toss magnitude via sign
s = sign(sum(d,2));

% Return the following for comparison flags:
% the first element of compareAcross to be one (easy enough); for
% the second element, return 0 if cas{2} is equal to cas{1} or return
% one if cas{2} is not equal to cas{1} and do likewise for subsequent
% elements (so test cas{3} = cas{2} and so on):
blnAcross = [1 s'];

% ---------------------------------------------
function r = locGetUnusedReplacementForSpace(c)
str = '~!@#$%^&*'; % candidates for replacement
d = setdiff(str,c(:));
if isempty(d)
    error('daly:bci:compareacross:noSuitableReplacementFound','no suitable replacement string value found');
end
r = abs(d(1));