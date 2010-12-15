function [varout1,varout2,varout3,varout4] = euler2quat (varargin);

%  EULER2QUAT calculates the yaw,pitch,roll sequence from quaternion formulation. Default values for
% the angles are in degrees.  Q is a Nx4 matrix, [q0 q1 q2 q3] 
% USAGE:
%    [output] = euler2quat(input)  where any combination of the following options can be used
% 
% Input options:
%     (RPY)       where RPY = [roll pitch yaw] angles in degrees
%     (RPY,'rad') where RPY = [roll pitch yaw] angles in radians
%     (roll,pitch,yaw)
%     (roll,pitch,yaw,'rad')
% Output options:
%      [q1,q2,q3,q4]
%      [Q]        where Q = [q0 q1 q2 q3]   
%

%
% Author: Eric Kelly
% $Id: euler2quat.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Parse the inputs
switch(nargin)
case 1
   [var1]=deal(varargin{:});
   roll = var1(:,1);
   pitch = var1(:,2);
   yaw = var1(:,3);
   radflag = 'deg';
   
case 2
   [var1,radflag]=deal(varargin{:});
   roll = var1(1);
   pitch = var1(2);
   yaw = var1(3);
   
case 3
   [roll,pitch,yaw] = deal(varargin{:});
   roll = roll(:);pitch=pitch(:);yaw = yaw(:);
   radflag = 'deg';
case 4
   [roll,pitch,yaw,radflag] = deal(varargin{:});
   roll = roll(:);pitch=pitch(:);yaw = yaw(:);
otherwise 
   disp('Incorrect input. Try again');
end

% Convert if not in radians already
if ~strcmp(radflag,'rad')
   roll = roll * (pi/180);
   pitch = pitch * (pi/180);
   yaw = yaw * (pi/180);
end

% Calculate cosines and sines
cr = cos(roll/2);
cp = cos(pitch/2);
cy = cos(yaw/2);
sr = sin(roll/2);
sp = sin(pitch/2);
sy = sin(yaw/2);

Q = zeros(size(roll,1),4);

% Calculate the quaternion
Q(:,1) =  cr.*cp.*cy + sr.*sp.*sy;
Q(:,2) =  sr.*cp.*cy - cr.*sp.*sy;
Q(:,3) =  cr.*sp.*cy + sr.*cp.*sy;
Q(:,4) =  cr.*cp.*sy - sr.*sp.*cy;

% Both Q an -Q satisfy equations, choose Q where q(1) is positive
index = find(Q(:,1)<0);
if ~isempty(index)
   Q(index,:)=-Q(index,:);
end

% Correct for floating point accuracy
tol =  eps;
index = find(abs(Q)<tol);
Q(index) =0;


% Parse the outputs
if nargout==1
   varout1 = Q;
elseif nargout==4
   varout1 = Q(1);
   varout2 = Q(2);
   varout3 = Q(3);
   varout4 = Q(4);
end
