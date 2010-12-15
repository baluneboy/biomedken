function [A] = ArotN(rates,varargin)

% This function creates a 3x3xN rotational accleration matrix. 
% The functionality is:
%               [A] = Arot (rates)            ANGLULAR VELOCITY IN DEGREES/sec
%               [A] = Arot (rates,'rad')      ANGLULAR VELOCITY IN RADIANS/sec
%
% rates = [wx wy wz] x N, where N is the time axis
%

%
% Author: Eric Kelly
% $Id: ArotN.m 4160 2009-12-11 19:10:14Z khrovat $
%

rates = reshape(rates',1,3,size(rates,1));

if nargin==1 
   rates = rates * pi/180;
elseif nargin ==2
   israd = deal(varargin{:});
   if strcmp(israd ,'deg');
      rates = rates * pi/180; 
   else 
      % do nothing rates are in radians already
   end
else
   disp('Incorrect parameters passed into Arot');
   return;
end

wxwy = rates(:,1,:).*rates(:,2,:);       %wx.*wy
wxwz = rates(:,1,:).*rates(:,3,:);       %wx.*wz
wywz = rates(:,2,:).*rates(:,3,:);       %wy.*wz
wx2 =  rates(:,1,:).*rates(:,1,:);       %wx.*wx
wy2 =  rates(:,2,:).*rates(:,2,:);       %wy.*wy
wz2 =  rates(:,3,:).*rates(:,3,:);       %wz.*wz

clear rates;

% A = w x w x r
% w0^2 = sum(diag(A))/-2
% This is the opposite of matisaks paper, he has A = -w x w x r
% This is the science/orbiter thing

A = [-(wy2+wz2)   wxwy       wxwz;...
          wxwy    -(wx2+wz2)   wywz;...
          wxwz       wywz   -(wx2+wy2)];
