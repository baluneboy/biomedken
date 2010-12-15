function [Typr] = euler2Typr (var1,var2,var3,var4)
% This function creates a  pitch,yaw roll transformation matrix. 
% The functionality is:
%
%               [T] = euler2Typr (RPY)            ANGLES IN DEGREES   
%               [T] = euler2Typr (RPY,'rad')      ANGLES IN RADIANS   where rpy = [roll pitch yaw]
%                             or
%               [T] = euler2Typr (roll,pitch,yaw)            ANGLES IN DEGREES
%               [T] = euler2Typr (roll,pitch,yaw,'rad')      ANGLES IN RADIANS
%
% Yaw, pitch and roll are rotation angles relative to SS Analysis coordinates.
%
% THE SEQUENCE OF ROTATIONS IN DETERMINING THE MATRIX IS YAW-PITCH-ROLL
%

%
% Author: Eric Kelly
% $Id: euler2Typr.m 4160 2009-12-11 19:10:14Z khrovat $
%

if (nargin == 1 | nargin == 2)
   roll = var1(1);
   pitch = var1(2);
   yaw = var1(3);
   if nargin == 2
      israd = var2;
   end   
elseif(nargin == 3 | nargin == 4)
   roll = var1;
   pitch=var2;
   yaw = var3;
    if nargin == 4
      israd = var4;
   end 
else
  disp('Incorrect parameters passed into Typr');
  return; 
end

% Convert from degrees to radians if desired
if (nargin==1 | nargin == 3) 
   yaw = yaw * pi/180;
   pitch = pitch * pi/180;
   roll = roll * pi/180;
elseif ( (nargin ==2 | nargin ==4) & strcmp(israd,'rad'))
   % do nothing yaw,pitch, and roll are in radians already
else
   disp('Incorrect parameters passed into Typr');
   return;
end

% calculate sins and cosines
cp= cos(pitch); sp = sin(pitch);
cy = cos(yaw);  sy = sin(yaw);
cr = cos(roll); sr = sin(roll);

% calculate elements of the array
T11 = cp * cy;
T12 = cp*sy;
T13 = -sp;

T21 = sr*sp*cy - cr*sy;
T22 = sr*sp*sy + cr*cy;
T23 = sr*cp;

T31 = cr*sp*cy + sr*sy;
T32 = cr*sp*sy - sr*cy;
T33 = cr*cp;

Typr = [T11 T12 T13; T21 T22 T23; T31 T32 T33];


% Correct for floating point accuracy
tol =  eps;
index = find(abs(Typr)<tol);
Typr(index) =0;
