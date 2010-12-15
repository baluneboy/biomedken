function angle_deg = anglebetweenvectorandplane(v,p1,p2,p3)
% anglebetweenvectorandplane - find angle between a vector and a plane defined by 3 points
%
% angle_deg = anglebetweenvectorandplane(v,p1,p2,p3);
%
% INPUTS:
% v - vector in "global" coordinates; should be in nx3 matrix form, where n
% is number of sample points, [col1 col2 col3] = [x y z]
% p1,p2,p3 - coordinates of points in "global" coordinates; each should
% also be in nx3 matrix form.
%
% OUTPUTS:
% angle_deg - scalar angle between vector and plane in degrees
%
% EXAMPLE:
% v = [2 2 2; 3 3 3]; % the vector
% p1 = [0 0 0; 1 0 0; 2 0 0; 3 0 0];
% p2 = [1 0 0; 2 0 0; 3 0 0; 4 0 0];
% p3 = [0.5 1 0; 1.5 1 0; 2.5 1 0; 3.5 1 0];
% angle_deg = anglebetweenvectorandplane(v,p1,p2,p3) % trivial example should give 35.26 deg as result

% Author: Krisanne Litinas
% $Id: anglebetweenvectorandplane.m 4160 2009-12-11 19:10:14Z khrovat $
% $Id: anglebetweenvectorandplane.m 4160 2009-12-11 19:10:14Z khrovat $

% Use 3 points on the plane to find two co-planar vectors
firstVectorOnPlane = p2 - p1;
secondVectorOnPlane = p3 - p1;


vectorPerpendicularToPlane = cross(firstVectorOnPlane, secondVectorOnPlane, 2);

% Get coordinate system of plane 
x_hat = diag(1./vnorm(firstVectorOnPlane, 2)) * firstVectorOnPlane;
z_hat = diag(1./vnorm(vectorPerpendicularToPlane, 2)) * vectorPerpendicularToPlane;
y_hat = cross(z_hat, x_hat, 2);


% calculate angle_deg
angle_deg = 90 - acos((dot(z_hat, v, 2) ./ (vnorm(v, 2) .* vnorm(z_hat, 2))));

