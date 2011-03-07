function c = casinterleave(a,b)

% EXAMPLE
% a = {'one','uno'}';
% b = {'two','dos'}';
% c = casinterleave(a,b)

% FIXME please, this was done ad hoc
if nCols(a)~=1 || nCols(b)~=1
    error('need columns of cas as input')
end
if nRows(a) ~= nRows(b)
    error('need same # rows in each input')
end
c = {};
for i = 1:nRows(a)
    c = cappend(c,a{i});
    c = cappend(c,b{i});
end
