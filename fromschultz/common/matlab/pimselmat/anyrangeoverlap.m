function [bln,ind] = anyrangeoverlap(r)
% ANYRANGEOVERLAP - check if any rows of range matrix, r, have overlap
%
% INPUTS:
% r - Nx2 matrix of range values [RNGMIN(:) RNGMAX(:)]
%
% OUTPUTS:
% bln - boolean true if there are overlaps; otherwise, false

% Author: Ken Hrovat
% $Id$

%% Do diagonal diff for successive, row-to-row differences
dd = diagdiff(r);

%% Find overlaps
ind = find(dd<=0);

%% Check if any overlap exists
bln = ~isempty(ind);