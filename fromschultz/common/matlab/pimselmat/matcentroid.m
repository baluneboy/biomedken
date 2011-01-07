function [iCentroid, weightCentroid] = matcentroid(m)
% matcentroid.m - returns index and value at index of centroid of a 2D or
% 3D matrix
%
% INPUTS
% m - 2D or 3D matrix
%
% OUTPUTS
% iCentroid - index (i,j) for 2D or (i,j,k) for 3D of centroid
% weightCentroid - weight of the centroid, sum for no
%
% EXAMPLE
% m = [1 1 1; 1 2 1; 1 1 1];
% [iCentroid, weightCentroid] = matcentroid(m)
% OR
% m = ones(3,3,3);
% m(:,:,2) = [1 1 1; 1 2 1; 1 1 1];
% [iCentroid, weightCentroid] = matcentroid(m)

% Author - Krisanne Litinas
% $Id$

mDims = size(m);
y = 1:mDims(1);
x = 1:mDims(2);

% Account for 2D or 3D input
switch numel(mDims)
    case 2
        [x,y] = meshgrid(x,y);
        iCentroid = [sum(m(:).*x(:)) sum(m(:).*y(:))]/sum(m(:));

    case 3
        z = 1:mDims(3);
        [x,y,z] = meshgrid(x,y,z);
        iCentroid = [sum(m(:).*x(:)) sum(m(:).*y(:)) sum(m(:).*z(:))]/sum(m(:));

        % For 3D do conversion [wtf?  I don't know why this works]
        xOffset = mDims(1) + 1;
        % iCentroid = [158-iCentroid(2) iCentroid(1) iCentroid(3)];
        iCentroid = [xOffset-iCentroid(2) iCentroid(1) iCentroid(3)];
end

% Get the mass
weightCentroid = sum(m(:));