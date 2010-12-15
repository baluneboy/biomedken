function [T] = quat2Typr (varargin);

%  QUAT2TYPR calculates the  transformation matrix from a quaternion for a YPR sequence of rotations.
%    
%   [T] = quat2Typr(Q);      Q is a vector [q1;q2;q3;q4]
%   [T] = quat2Typr(q1,q2,q3,q4);
% 

%
% Author: Eric Kelly
% $Id: quat2Typr.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Parse the Inputs
if nargin == 1 
   [Q]=deal(varargin{:});
   q0 = Q(1);
   q1 = Q(2);
   q2 = Q(3);
   q3 = Q(4);
elseif nargin == 4
   [q0,q1,q2,q3]=deal(varargin{:}); 
else
  disp('Incorrect parameters passed into quat2Typr');
  return; 
end
   
T = zeros(3,3);

T = [((q0^2)+(q1^2)-(q2^2)-(q3^2))      (2*(q1*q2 + q0*q3))            (2*(q1*q3 - q0*q2));...
           (2*(q1*q2 - q0*q3))     ((q0^2)-(q1^2)+(q2^2)-(q3^2))      (2*(q2*q3 + q0*q1));...
          (2*(q1*q3 + q0*q2))         (2*(q2*q3 - q0*q1))         ((q0^2)-(q1^2)-(q2^2)+(q3^2))];
     
     
% Correct for floating point accuracy
tol =  eps;
index = find(abs(T)<=tol);
T(index) =0;

