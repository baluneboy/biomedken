function [vSort,ix,iy,iz] = sort3d(m,strMode)
% sort3d - sorts 3D array
% 
% INPUTS
% m - 3D array of doubles
% strMode - sort order, 'ascend' or 'descend'
% 
% OUTPUTS
% vSort - column vector, size numel(m) containing elements of m sorted
% ix - column vector, x indices of sorting (size = numel(m))
% iy - column vector, y indices of sorting (size = numel(m))
% iz - column vector, z indices of sorting (size = numel(m))

% EXAMPLE
% m = [2 5 1; 4 0 7; 11 3 9];
% m(:,:,2) = [1.5 7.1 12; -1 14 -7; 6 8 -2];
% [vSort,ix,iy,iz] = sort3d(m,'descend') OR
% [vSort,ix,iy,iz] = sort3d(m,'ascend')

% Author - Krisanne Litinas
% $Id$

vm = m(:);
[vSort,iSort] = sort(vm,strMode);
[ix,iy,iz]=ind2sub(size(m),iSort);