function [x,y] = circle(R,c,n)

% CIRCLE returns the x,y coordinates of a circle of radius R at center c.
% n is the number of points used in the circle.
%
%  [x,y] = SPHERE(R,c,n); 
%  [x,y] = SPHERE(R) returns a 20 point circle of radius R, at c(0,0)
%  [x,y] = SPHERE(R,c) returns a 20 point circle of radius R, at c(xc,yc)
%  [x,y] = SPHERE(R,[],n) returns a n point circle of radius R, at c(0,0)

%
% Author: Eric Kelly
% $Id: circle.m 4160 2009-12-11 19:10:14Z khrovat $
%

if nargin == 0
   R = 1
   c = [0 0];
   n = 20; 
elseif nargin ==1
   c = [0 0]
   n =20;
elseif nargin ==2;
   n =20;
end

if isempty(c)
   c = [0 0];
elseif length(c) ~=2
  error('Must have and x and y coordinates for center'); 
end

% -pi <= theta <= pi 
theta = (-n:2:n)/n*pi;

x = R*cos(theta) + c(1);
y = R*sin(theta) + c(2);
