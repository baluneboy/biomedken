function yy = linterp(x,y,xx)
%LINTERP Linear interpolation.
%
% YY = LINTERP(X,Y,XX) does a linear interpolation for the given
%      data:
%
%           y: given Y-Axis data
%           x: given X-Axis data
%          xx: points on X-Axis to be interpolated
%
%      output:
%
%          yy: interpolated values at points "xx"

% modified by: Kenneth Hrovat on 4/17/1998 for speed increase
% $Id: linterp.m 4160 2009-12-11 19:10:14Z khrovat $
% R. Y. Chiang & M. G. Safonov 9/18/1988
% Copyright (c) 1988-97 by The MathWorks, Inc.
%       $Revision: 1.1.1.1 $
% All Rights Reserved.
% ------------------------------------------------------------------

nx = max(size(x));
nxx = max(size(xx));
if xx(1) < x(1)
   error('You must have min(x) <= min(xx)..')
end
if xx(nxx) > x(nx)
   error('You must have max(xx) <= max(x)..')
end
%
j = 2;
yy=zeros(nxx,1); % ADDED FOR SPEED INCREASE
for i = 1:nxx
   while x(j) < xx(i)
         j = j+1;
   end
   alfa = (xx(i)-x(j-1))/(x(j)-x(j-1));
   yy(i) = y(j-1)+alfa*(y(j)-y(j-1));
end
%
% ------ End of INTERP.M % RYC/MGS %