function [varout1,varout2,varout3,varout4] = eigen2quat (varargin);

% QUAT2EIGEN calculates the theta,alpha,beta and gamma from quaternions. Default values for
% the angles are in degrees.  M is a 3x3 matrix. 
%
%		[theta,alpha,beta,gamma] = quat2eigen (E)     for angles in degrees
%		[theta,alpha,beta,gamma] = quat2eigen (E,'rad') for angles in radians

%
% Author: Eric Kelly
% $Id: eigen2quat.m 4160 2009-12-11 19:10:14Z khrovat $
%

switch(nargin)
case 1
   [var1]=deal(varargin{:});
   theta = var1(1);
   alpha = var1(2);
   beta = var1(3);
   gamma = var1(4);
   radflag = 'deg';
   
case 2
   
   [var1,radflag]=deal(varargin{:});
   theta = var1(1);
   alpha = var1(2);
   beta =  var1(3);
   gamma = var1(4);
   
case 4
   [theta,alpha,beta,gamma] = deal(varargin{:});
   radflag = 'deg'
case 5
   [theta,alpha,beta,gamma,radflag] = deal(varargin{:});
otherwise 
   disp('Incorrect input. Try again');
end


% Convert if not in radians already
if ~strcmp(radflag,'rad')
   theta = theta*(pi/180);
   alpha =alpha*(pi/180);
   beta = beta*(pi/180);
   gamma = gamma*(pi/180);
end

Q = zeros(4,1);
sth2 = sin(theta/2);

Q(1) = cos(theta/2);
Q(2) = cos(alpha)*sth2;
Q(3) = cos(beta)*sth2;
Q(4) = cos(gamma)*sth2;

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
else
   disp('Incorrect number of output arguements.');
end



   