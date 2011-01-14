function [iCentroid, weightCentroid] = matcentroid(m,strOrient)
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
% m = [1 1 1 1; 1 2 1 1; 1 1 1 1];
% [iCentroid, weightCentroid] = matcentroid(m)
% OR
% m = ones(3,3,3);
% m(:,:,2) = [1 1 1; 1 1 2; 1 1 1];
% [iCentroid, weightCentroid] = matcentroid(m)

% Author - Krisanne Litinas
% $Id$

mDims = size(m);
y = 1:mDims(1);
x = 1:mDims(2);

if nargin == 1
    strOrient = 'xyz';
elseif ~strcmpi(strOrient,'ras') && ~strcmpi(strOrient,'xyz')
    error('elmat:invalidindexmode','strOrient should be "xyz" or "ras"');
end

% Account for 2D or 3D input
switch numel(mDims)
    case 2
        [x,y] = meshgrid(x,y);
        iCentroid = [nansum(m(:).*x(:)) nansum(m(:).*y(:))]/nansum(m(:));

    case 3
        z = 1:mDims(3);
        [x,y,z] = meshgrid(x,y,z);
        iZero = find(m==0);
        m(iZero) = nan;

        % Normalize (shady)
            scaler = min(m(:));
            if scaler < 0
                m = m + abs(scaler);
            else
                m = m-abs(scaler);
            end
        
        iCentroid = [nansum(m(:).*x(:)) nansum(m(:).*y(:)) nansum(m(:).*z(:))]/nansum(m(:));

        % For 3D do conversion flip x, y dims
        % Apply offset for x-dim [wtf?  I don't know why this works]
        if strcmpi(strOrient,'ras')
            xOffset = mDims(1) + 1;
            error('probably broken/wrong strOrient')
        else
            xOffset = 0;
            iCentroid(2) = -iCentroid(2);
        end
        iCentroid = [xOffset-iCentroid(2) iCentroid(1) iCentroid(3)];
end

% Get the mass
weightCentroid = nansum(m(:));