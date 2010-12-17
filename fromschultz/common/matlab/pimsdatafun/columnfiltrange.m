function m2 = columnfiltrange(m,rng)
% columnfiltrange filter columns of m using ranges in rng; set NaN values outside the range
%
% INPUTS:
% m - RxC matrix to be "filtered"
% rng - 2xC matrix of ranges
%
% OUTPUTS:
% m2 - RxC matrix same as m except with NaNs at locations where m is outside rng (per column)
%
% EXAMPLE
% m = magic(3)
% rng = [2 6; 1 8; 5 9]'
% m2 = columnfiltrange(m,rng)

% Author: Ken Hrovat
% $Id$

%% Not very elegant, but it is effective

%% Crude error checking
if nCols(rng)~=nCols(m)
    error('daly:bci:mismatchInputs','both inputs need same number of columns')
end

%% Initialize output to all NaNs, then insert inputs that are within range
m2 = nan(size(m));
for c = 1:nCols(rng)
    cRng = sort(rng(:,c));
    ind = find(m(:,c)>=cRng(1) & m(:,c)<=cRng(2));
    m2(ind,c) = m(ind,c);
end