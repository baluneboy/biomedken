function s = planeside(A,B,C,D,x,y,z)
% The sign of s = Ax + By + Cz + D determines which side the point (x,y,z)
% lies with respect to the plane (A,B,C,D). If s > 0 then the point lies on
% the same side as the normal (A,B,C). If s < 0 then it lies on the
% opposite side, if s = 0 then the point (x,y,z) lies on the plane.
s = sign(A*x+B*y+C*z+D);