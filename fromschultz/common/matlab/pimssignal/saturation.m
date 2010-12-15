function [y,flag]=saturation(x,ymin,ymax);

%SATURATION (non-linear) function to limit output to be within saturation values range of [ymin,ymax]
%
%[y,flag]=saturation(x,ymin,ymax);
%
%Inputs: x - vector of inputs
%        ymin - scalar for lower limit
%        ymax - scalar for upper limit
%
%Output: y - vector of potentially saturated outputs
%        flag - vector of flags that indicate condition
%               if x(i)>ymax, then flag(i)=+1;
%               if x(i)<ymin, then flag(i)=-1;
%               if ymin<=x(i)<=ymax, then flag(i)=0;

% written by: Ken Hrovat on 3/27/00
% $Id: saturation.m 4160 2009-12-11 19:10:14Z khrovat $

% Error check inputs:
if ymin>=ymax
	error('ymin must be strictly less than ymax')
end

% Initialize
y=x;
flag=zeros(size(y));

inan=find(isnan(y));

flag(inan)=NaN;

% Saturate at lower bound
ineg=find(y<ymin);
y(ineg)=ymin;
flag(ineg)=-1;

% Saturate at upper bound
ipos=find(y>ymax);
y(ipos)=ymax;
flag(ipos)=1;