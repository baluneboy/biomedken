function [Typr] = quatTyprN(varargin)
% quat2TyprN creates a 3x3xN transformation matrix for a yaw pitch roll sequence.  This is primarily used
% for when the transformation matrix varies with time, which is the N axis.
% The functionality is:
%
%      [Typr] = TyprN ([q0 q1 q2 q3])
% ypr refers to the sequence of Rotations NOT the order of parameters to be passed in

%
% Author: Eric Kelly
% $Id: quat2TyprN.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Parse the Inputs
if nargin == 1 
   [Q]=deal(varargin{:});
   q0 = Q(:,1);
   q1 = Q(:,2);
   q2 = Q(:,3);
   q3 = Q(:,4);
elseif nargin == 4
   [q0,q1,q2,q3]=deal(varargin{:}); 
else
  disp('Incorrect parameters passed into quat2Typr');
  return; 
end
clear varargin;

% Reshape the matrix to vectorize operations
lengthQ = size(Q,1);
q0 = reshape(q0,1,1,lengthQ);
q1 = reshape(q1,1,1,lengthQ);
q2 = reshape(q2,1,1,lengthQ);
q3 = reshape(q3,1,1,lengthQ);
clear Q;

% calculate elements of the array
T11 = (q0.^2)+(q1.^2)-(q2.^2)-(q3.^2);
T12 = 2*(q1.*q2 + q0.*q3);
T13 = 2*(q1.*q3 - q0.*q2);

T21 = 2*(q1.*q2 - q0.*q3);
T22 = (q0.^2)-(q1.^2)+(q2.^2)-(q3.^2);
T23 = 2*(q2.*q3 + q0.*q1);

T31 = 2*(q1.*q3 + q0.*q2);
T32 = 2*(q2.*q3 - q0.*q1);
T33 = (q0.^2)-(q1.^2)-(q2.^2)+(q3.^2);

Typr = zeros(3,3,lengthQ);
Typr = [T11 T12 T13; T21 T22 T23; T31 T32 T33];

% Correct for floating point accuracy
tol =  eps;
index = find(abs(Typr)<tol);
Typr(index) =0;