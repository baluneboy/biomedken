function [var1,var2,var3] = Typr2euler (M,radflag);

%  Typr2euler calculates the yaw,pitch,roll sequence from a transformation matrix. Default values for
% the angles are in degrees.  M is a 3x3 matrix. 
%
%		[roll,pitch,yaw] = Typr2euler (M)     for angles in degrees
%		[roll,pitch,yaw] = Typr2euler(M,'rad') for angles in radians
%

%
% Author: Eric Kelly
% $Id: Typr2euler.m 4160 2009-12-11 19:10:14Z khrovat $
%

if (nargin ==1)  
  radflag = 'deg';
elseif (nargin==2) & (radflag=='rad')
   %do nothing, pitch,yaw,roll already in radians
else 
   disp('Incorrect input. Try again');
end

   
% The case where not both m23 and m33 are zero
if ~( M(2,3)==0 & M(3,3) ==0 )
   yaw = atan2(M(1,2),M(1,1));
   pitch = atan2(-M(1,3),sqrt(1-M(1,3)^2));
   roll = atan2(M(2,3),M(3,3));
   
% The case where m23=m33=0
else
   % m13 = -1
   if M(1,3) == -1
      pitch = pi/2;
      yaw = 0;
      roll = atan2(M(2,1),M(2,2));
   % m13 =1
   else
      pitch = -pi/2;
      yaw = 0;
      roll = atan2(-M(2,1),-M(3,1));
   end
end

% Convert to degrees if necessary
if radflag == 'deg'
  pitch = pitch*180/pi;
  yaw = yaw*180/pi;
  roll = roll*180/pi;
end

if nargout==1
   var1 = [roll pitch yaw];
   var2 =0;var3=0;
else
   var1 = roll;
   var2 = pitch;
   var3 = yaw;
end


   