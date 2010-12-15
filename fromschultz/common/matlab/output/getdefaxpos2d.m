function posAxes=getdefaxpos2d(numy,r,sReport,strDevType);

%getdefaxpos2d - get default axes position(s) for 2d generic plot
%
%posAxes=getaxpos2d(numy,r,sReport);
%
%Inputs: numy - scalar number of axes (1 or 3)
%        r - scalar for which axes (1, 2, or3)
%        sReport - structure of
%
%Outputs: posAxes - 4-element vector for axes position [x y w h]

%Author: Ken Hrovat, 2/1/2001
% $Id: getdefaxpos2d.m 4160 2009-12-11 19:10:14Z khrovat $

switch strDevType
case {'screen','datafilebat','imagefilebat'}
   if numy==1
      posAxesX=0.11;
      posAxesY=0.08;
      posAxesW=0.81;
      posAxesH=0.82;
   else %3x1
      yAxesLowest=0.06;
      posAxesX=0.11;
      posAxesY=yAxesLowest+0.29*(3-r);
      posAxesW=0.81;
      posAxesH=0.26;
   end
otherwise
   if numy==1
      posAxesX=0.11;
      posAxesY=0.08;
      posAxesW=0.81;
      posAxesH=0.66; % fix this
   else %3x1
      yAxesLowest=0.06;
      posAxesX=0.11;
      posAxesY=yAxesLowest+0.29*(3-r);
      posAxesW=0.81;
      posAxesH=0.16; % fix this
   end
end % switch strDevType

posAxes=[posAxesX posAxesY posAxesW posAxesH];
