function [var1,var2,var3,var4] = Typr2eigen (M,radflag);

%  MATRIX2EIGEN calculates axis/angle representation  from a transformation matrix. Default values for
% the angles are in degrees.  M is a 3x3 matrix. 
%
%		[theta,alpha,beta,gamma] = matrix2eigen (M)     for angles in degrees
%		[theta,alpha,beta,gamma] = matrix2eigen (M,'r') for angles in radians
%

%
% Author: Eric Kelly
% $Id: Typr2eigen.m 4160 2009-12-11 19:10:14Z khrovat $
%


% Correct for floating point accuracy
tol =  eps;

if (nargin ==1)  
  radflag = 'deg';
elseif (nargin==2) & (radflag=='rad')
   %do nothing angles will already be in radians
else 
   disp('Incorrect input. Try again');
end

% Find theta
tr = trace(M);
theta = acos((tr-1)/2);

% Find the angles and unit vector k
if tr==3
   % no rotations
   alpha = 0;
   beta =0;
   gamma=0
elseif tr==-1
   if M(1,1)==1
      % rotation of 180 about x-axis (roll)
      alpha =0;beta=pi/2;gamma=pi/2;
   elseif M(2,2)==1
      % rotation of 180 about y-axis (pitch)
      alpha =pi/2;beta=0;gamma=pi/2;
   elseif M(3,3)==1
      % rotation of 180 about z-axis (yaw)
      alpha=pi/2;beta=pi/2;gamma=0;
   end
else
   k = (1/(2*sin(theta)))*[M(2,3)-M(3,2) M(3,1)-M(1,3) M(1,2)-M(2,1)];
   alpha = acos(k(1));
   beta = acos(k(2));
   gamma = acos(k(3));
end

% Convert to degrees if necessary
if radflag == 'deg'
  theta = theta*180/pi;
  alpha = alpha*180/pi;
  beta = beta*180/pi;
  gamma = gamma*180/pi;
end

if nargout==1
   var1 = [theta alpha beta gamma];
   var2 =0;var3=0;;var4=0;
else
   var1 = theta;
   var2 = alpha;
   var3 = beta;
   var4 = gamma;
end


   