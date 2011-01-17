function [c] = redblue(m)
%
% redblue Shades of red to white to blue colormap.
% REDBLUE(M) returns an M-by-3 matrix containing a
% "redblue" colormap.
% CAVEAT this actually only works properly for even length
% colormaps. Some fiddling will get it to work generally.
%
% See also HSV, COLORMAP, RGBPLOT.

%
% Copyright Jody Klymak, 1998 jklymak@apl.washington.edu
% Do not distribute w/o this copyright notice.
%

if nargin<1
  [m,n] = size(colormap);
end;

m0=floor(m*0.0);
m1=floor(m*0.20);
m2=floor(m*0.20);
m3=floor(m/2)-m2-m1;

b_= [ 0.4*(0:m1-1)'/(m1-1)+0.6; ones(m2+m3,1)];
g_= [zeros(m1,1); (0:m2-1)'/(m2-1);ones(m3,1)];
r_= [zeros(m1,1); zeros(m2,1); (0:m3-1)'/(m3-1)];

r=[r_; flipud(b_)];
g=[g_; flipud(g_)];
b=[b_; flipud(r_)];

c=[r g b];


function [cm] = coldhot(m)
%
% COOLHOT Shades of purple to blue to white to red to yellow colormap.
% COLDHOT(M) returns an M-by-3 matrix containing a
% "coldhot colormap"
%
% See also HSV, COLORMAP, RGBPLOT.

%
% Copyright Jody Klymak, 1998 jklymak@apl.washington.edu
% Do not distribute w/o this copyright notice.
%

if nargin<1
 [m,n] = size(colormap);
end;

hs=flipud(hsv(ceil(2.91*m*1/3)));
ch=brighten(coolhot(ceil(m*1/3)),0.5);
aut=brighten(autumn(ceil(m*1/3)),0.5);
mm=m*1/3;
cm = [hs(1:mm,:); ch; aut(1:mm,:)];

%cm = flipud([r,g,b]);
% darken so that transparencies look good.
%cm = brighten(cm,-0.3);
