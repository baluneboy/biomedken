function [Typr] = TyprN(rpy,israd)
% TyprN creates a 3x3xN transformation matrix for a yaw pitch roll sequence.  This is primarily used
% for when the transformation matrix varies with time, which is the N axis.
% The functionality is:
%
%      [Typr] = TyprN ([roll pitch yaw])           ANGLES IN DEGREES
%      [Typr] = Typr ([roll pitch yaw],'rad')      ANGLES IN RADIANS
%
%
%                         ******** NOTE THE ORDER ******** 
% [roll pitch yaw] is a  1x3xN matrix of rotation angles. (i.e. [roll pitch yaw] x N)
%                                                   ----- --- ----
% ypr refers to the sequence of Rotations NOT the order of parameters to be passed in

%
% Author: Eric Kelly
% $Id: TyprN.m 4160 2009-12-11 19:10:14Z khrovat $
%


if nargin==1 
   rpy = rpy * pi/180;
   
elseif (nargin ==2 & strcmp(israd,'rad'))
   % do nothing pitch, yaw, and roll are in radians already
else
   disp('Incorrect parameters passed into Typr');
   return;
end


% calculate sins and cosines 

%  Roll is rpy(:,1,:)
%  Pitch is rpy(:,2,:)
%  Yaw is rpy(:,3,:)
cr = cos(rpy(:,1,:)); sr = sin(rpy(:,1,:));
cp = cos(rpy(:,2,:)); sp = sin(rpy(:,2,:));
cy = cos(rpy(:,3,:)); sy = sin(rpy(:,3,:));


clear rpy;

% calculate elements of the array
T11 = cp .* cy;
T12 = cp.*sy;
T13 = -sp;

T21 = sr.*sp.*cy - cr.*sy;
T22 = sr.*sp.*sy + cr.*cy;
T23 = sr.*cp;

T31 = cr.*sp.*cy + sr.*sy;
T32 = cr.*sp.*sy - sr.*cy;
T33 = cr.*cp;

Typr = [T11 T12 T13; T21 T22 T23; T31 T32 T33];

% Correct for floating point accuracy
tol =  eps;
index = find(abs(Typr)<tol);
Typr(index) =0;