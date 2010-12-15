function [angle_deg, angle_rad] = anglebetweenvectors(a,b)

% anglebetweenvectors - find angle between 2 vectors (in great circle sense)
%
% [angle_deg, angle_rad] = anglebetweenvectors(a,b);
%
% INPUTS:
% a,b - vectors for either 2D (x,y) or 3D (x,y,z) components
%
% OUTPUTS:
% angle_deg - scalar angle between vectors in degrees
% angle_rad - scalar angle between vectors in radians
%
% EXAMPLE:
% a = [ 1 0 0 ]; % reference vector along +ive x-axis
% theta = 0:pi/9:2*pi; % every 20 degrees
% for i = 1:length(theta)
%   b = [ cos(theta(i)) sin(theta(i)) 0 ]; % SOHCAHTOA
%   angle = anglebetweenvectors(a,b);
%   fprintf('\ntheta = %5.1f, angle = %5.1f degrees',theta(i)*180/pi, angle)
% end
%

% notes: this function might be more useful if we would allow it to work
% column-wise on matrix inputs (too much other work for now though)

% Author: Ken Hrovat (as described by Roger Stafford) $Id:
% anglebetweenvectors.m 2223 2008-09-09 14:34:26Z khrovat $

% Verify inputs and coerce them into column shape
a = locColumnVec(a);
b = locColumnVec(b);

% Append z = 0 (if needed) for 3D
a = locThreeD(a);
b = locThreeD(b);

% Result in radians
angle_rad = atan2(norm(cross(a,b)),dot(a,b));

% Convert to degrees
angle_deg = angle_rad * 180/pi;

% ----------------------------
function out = locColumnVec(a)
if isrow(a)
    out = a(:);
elseif ~iscol(a)
    error('inputs must be row or column vector')
else
    out = a;
end

% -------------------------
function out = locThreeD(a)
switch length(a)
    case 3
        out = a;
    case 2
        out = [a; 0];
    otherwise
        error('input must have 2 or 3 components for 2D (x,y) or 3D (x,y,z)')
end