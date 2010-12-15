function quadNum = getquadrant(x,y)

%Function determines what quadrant the target appeared in
%
%INPUT: x,y coordinates in meters
%
%OUTPUT: the quadrant number, quadNum.  
% 1 is from 0 to 90 degrees
% 2 is 90 to 180 degrees
% 3 is 180 to 270 degrees
% 4 is 270 to 360 degrees
%
%EXAMPLE quadNum = getquadrant(x,y)
%

%Author: Ken Hrovat
%$Id: getquadrant.m 4160 2009-12-11 19:10:14Z khrovat $

ttheta = atan2(y,x)*180/pi;

if and(ttheta >= 0,ttheta < 90)==1
    quadNum = 1;
elseif and( ttheta >= 90, ttheta < 180 )==1
    quadNum = 2;
elseif and( ttheta <= -90, ttheta > -180 )==1
    quadNum = 3;
elseif and( ttheta < 0, ttheta >= -90 )==1
    quadNum = 4;
else
    error('getquadrant:NaN',...
        'Quadrant could not be found in getquadrant.  Please, somebody fix all the nooks and crannies in serob files');
end