function posFigure=getdeffigpos(strOrient);

%getdeffigpos - get figure position 
%
%posFigure=getdeffigpos(strOrient);
%or
%
%
%Inputs: strOrient - string for orientation {'portrait' | 'landscape'}
%
%Outputs: posFigure - 4-element row vector [x y w h]

%Author: Ken Hrovat, 1/20/2001 (adapted from Habibzai's getfigpos)
% $Id: getdeffigpos.m 4160 2009-12-11 19:10:14Z khrovat $

% Some offset values
pixBottom=30; %taskbar height about 30 pix
pixTop=70;    %menu bars height about 60 pix

% Take care of settings for reset before leaving
oldRootUnits = get(0,'Units');
set(0, 'Units', 'pixels'); 
rootScreenSize = get(0,'ScreenSize');

% Portrait or landscape
if strcmp(lower(strOrient),'landscape')
   height=rootScreenSize(4)-pixTop-pixBottom;
   width=floor(height*11/8.5);
   left=floor((rootScreenSize(3)-width)/2);
else %portrait
   height=rootScreenSize(4)-pixTop-pixBottom;
   width=floor(height*8.5/11);
   left=floor((rootScreenSize(3)-width)/2);
end
bottom=1+pixBottom;

posFigure=[left bottom width height];

set(0, 'Units', oldRootUnits);

return

% (position is [x(from left) y(bottom edge from bottom) width height]
% check left edge and right edge
if ((posFigure(1) < 1) ...
      | (posFigure(1)+posFigure(3) > rootScreenSize(3)))
  posFigure(1) = 30;
end

% the figure 'position' does not include the menu bar or the title bar
% really, the default figure position should adjust for this, but
% for now, assume that the title and the menu bar take less than
% sixty pixels (need 30 pix for windows taskbar)
if ((posFigure(2)+posFigure(4)+60 > rootScreenSize(4)) ...
      | (posFigure(2) < 1))
  posFigure(2) = rootScreenSize(4) - posFigure(4) - 60;
end
set(0, 'Units', oldRootUnits);
