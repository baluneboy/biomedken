function dd = diagdiff(r)
% DIAGDIFF - diagonal diff (row1max - row2min) on Nx2 matrix of ranges
% [RNGMIN(:) RNGMAX(:)]
%
% INPUTS:
% r - Nx2 matrix of range values [RNGMIN(:) RNGMAX(:)]
%
% OUTPUTS:
% dd - (N-1)x1 vector of row-to-row differences

% Author: Ken Hrovat
% $Id$

%% Transpose for convenience
rt = r';

%% Diff everything
drt = diff(rt(:));

%% Return every other diff to get like (row1max - row2min)
dd = drt(2:2:end);