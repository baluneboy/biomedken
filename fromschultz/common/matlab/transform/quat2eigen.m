function [varout1,varout2,varout3,varout4] = quat2eigen (varargin);

% QUAT2EIGEN calculates the theta,alpha,beta and gamma from quaternions. Default values for
% the angles are in degrees.  M is a 3x3 matrix. 
%
%		[theta,alpha,beta,gamma] = quat2eigen (E)     for angles in degrees
%		[theta,alpha,beta,gamma] = quat2eigen (E,'rad') for angles in radians
%

%
% Author: Eric Kelly
% $Id: quat2eigen.m 4160 2009-12-11 19:10:14Z khrovat $
%

switch(nargin)
case 1
   [var1]=deal(varargin{:});
   q0 = var1(1);
   q1 = var1(2);
   q2 = var1(3);
   q3 = var1(4);
   radflag = 'deg';
   
case 2
   
   [var1,radflag]=deal(varargin{:});
   q0 = var1(1);
   q1 = var1(2);
   q2 = var1(3);
   q3 = var1(4);
   
case 4
   [q0,q1,q2,q3] = deal(varargin{:});
   radflag = 'deg'
case 5
   [q0,q1,q2,q3,radflag] = deal(varargin{:});
otherwise 
   disp('Incorrect input. Try again');
end


theta = 2*acos(q0);

if (theta~=0)
   % REAL function drops the imaginary part from the output of ACOS.  This
   % happens when q/sin(theta/2) is slightly greater than 1 because of a slight
   % error in tolerance.  i.e. 1+2e-16.  Could also round off q/sin(theta/2).
   alpha = real(acos(q1/sin(theta/2)));
   beta= real(acos(q2/sin(theta/2)));
   gamma = real(acos(q3/sin(theta/2)));
else
   % No rotations
   alpha =0;
   beta =0;
   gamma=0;
end

if strcmp(radflag,'deg')
   theta = theta*180/pi;
   alpha = alpha*180/pi;
   beta = beta*180/pi;
   gamma = gamma*180/pi;
elseif strcmp(radflag,'rad')
   % do nothing, angles in radians already
else
   disp('Bad value passed in for radflag');
end

% Parse the outputs
if nargout==1
   varout1 = [theta alpha beta gamma];
elseif nargout==3
   varout1 = theta;
   varout2 = alpha;
   varout3 = beta;
   varout4 = gamma;
else
   disp('Incorrect number of output arguements.');
end



   