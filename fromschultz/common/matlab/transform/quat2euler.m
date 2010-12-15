function [varout1,varout2,varout3] = quat2euler (varargin);

%  quat2euler calculates the Euler angles (roll,pitch,yaw) from quaternions. Default values for
% the angles are in degrees.  rpy is [roll pitch yaw] with roll,pitch and yaw being column vectors. 
%
%		[roll,pitch,yaw] = quat2euler (rpy)     for angles in degrees
%		[roll,pitch,yaw] = quat2euler (rpy,'rad') for angles in radians
%

%
% Author: Eric Kelly
% $Id: quat2euler.m 4160 2009-12-11 19:10:14Z khrovat $
%

switch(nargin)
case 1
   [var1]=deal(varargin{:});
  % var1 = var1(:); % ensures column vector
   q0 = var1(:,1);
   q1 = var1(:,2);
   q2 = var1(:,3);
   q3 = var1(:,4);
   radflag = 'deg';
   
case 2
   
   [var1,radflag]=deal(varargin{:});
   q0 = var1(:,1);
   q1 = var1(:,2);
   q2 = var1(:,3);
   q3 = var1(:,4);
   
case 4
   [q0,q1,q2,q3] = deal(varargin{:});
   radflag = 'deg'
case 5
   [q0,q1,q2,q3,radflag] = deal(varargin{:});
otherwise 
   disp('Incorrect input. Try again');
end

roll = atan2(2*(q2.*q3+q0.*q1),q0.^2-q1.^2-q2.^2+q3.^2);
pitch = atan2(-2*(q1.*q3-q0.*q2),sqrt(1-(2*(q1.*q3-q0.*q2)).*(2*(q1.*q3-q0.*q2))));
yaw = atan2(2*(q1.*q2+q0.*q3),(q0.^2+q1.^2-q2.^2-q3.^2));


%roll = atan(2*(q2.*q3+q0.*q1)./(q0.^2-q1.^2-q2.^2+q3.^2));
%pitch = atan(-2*(q1.*q3-q0.*q2)./sqrt(1-(2*(q1.*q3-q0.*q2)).*(2*(q1.*q3-q0.*q2))));
%yaw = atan(2*(q1.*q2+q0.*q3)./(q0.^2+q1.^2-q2.^2-q3.^2));

if strcmp(radflag,'deg')
   roll = roll*180/pi;
   pitch = pitch*180/pi;
   yaw = yaw*180/pi;
elseif strcmp(radflag,'rad')
   % do nothing, angles in radians already
else
   disp('Bad value passed in for radflag');
end

% Parse the outputs
if nargout==1
   varout1 = [roll pitch yaw];
elseif nargout==3
   varout1 = roll;
   varout2 = pitch;
   varout3 = yaw;
else
   disp('Incorrect number of output arguements.');
end



   