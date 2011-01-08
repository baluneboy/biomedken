function out = combinetheserows(x,ind)
% COMBINETHESEROWS combine successive rows in a Nx2 matrix at i & i+1 where
% i are elements of ind
%
% INPUTS:
% x - Nx2 matrix of range rows
% ind - index values to combine (that is, combine i & i+1)
%
% OUTPUTS:
% out - Mx2 matrix of range rows, possibly with some rows combined

% Author: Ken Hrovat
% $Id$

%% Initialize output
out = nan*ones(size(x));

%% Get indices of rows that will be combined & those not
indAll = 1:nRows(x);
indCombined = sort([ind(:); ind(:)+1]);
indNot = setdiff(indAll,indCombined);

%% Set rows that are not to be combined
if ~isempty(indNot)
    out(indNot,:) = x(indNot,:);
end

% Set rows that are to be combined
for i = 1:length(ind)
    r = ind(i);
    out(r,1) = x(r,1);
    out(r,2) = x(r+1,2);
end

% Remove nan rows
iNan = isnan(out(:,1));
out(iNan,:) = [];

