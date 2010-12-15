function [hFig,hAx]=plotsetupaxes(sizehAx);

%PLOTSETUPAXES - function to initialize figure axes (position, units, etc.).
%
%hAx=plotsetupaxes(hFig);
%
%Inputs: rows - scalar number of axes rows
%        cols - scalar number of axes cols
%
%Output: hFig - scalar handle of figure parent
%        hAx - matrix of axes handles

% written by: Ken Hrovat on 7/7/2000
% $Id: plotsetupaxes.m 4160 2009-12-11 19:10:14Z khrovat $

% Initialize figure
hFig=figure;
clf;
set(hFig,'color','w')

% Get width & height of screen in pixels
[screenWidth,screenHeight]=locGetScreenSize(0,'screensize'); %pixels

% Set figure screen position in pixels & paper position in inches
[figScreenPos,figPaperPos]=locSetFigPos(hFig,rows,cols,screenWidth,screenHeight);

% Create axes for subplots

ax1=axes;
ax2=axes;
ax3=axes;
set([ax1 ax2 ax3],'tickdir','out','fontname','times','box','on','unit','inch')
set(ax1,'position',[1.00 7.05 6.90 2.65])
set(ax2,'position',[1.00 3.90 6.90 2.65])
set(ax3,'position',[1.00 0.75 6.90 2.65])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pixwidth,pixheight]=locGetScreenSize;
xywh=get(0,'screensize');
pixwidth=xywh(3);
pixheight=xywh(4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [figScreenPos,figPaperPos]=locSetFigPos(hFig,rows,cols,screenWidth,screenHeight);
figScreenX=1;    figScreenY=1;		% lower-left corner of figure on screen (pixels)
figPaperX=0.25;   figPaperY=1.25;	% lower-left corner of figure on paper (inches)

rc=sprintf('%d-by-%d',rows,cols);
switch rc
case '3-by-1' % portrait
   orient(hFig,'tall');
   figScreenW=(8.5/11)*screenHeight;
   figScreenH=screenHeight;
   figPaperW= 8.00;
   figPaperH=10.50;
case '1-by-1' % landscape
   orient(hFig,'landscape');
   figScreenW=screenWidth;
   figScreenH=(8.5/11)*screenWidth;
   figPaperW=10.50;   
   figPaperH= 8.00;
otherwise
   strMsg=sprintf('no ''case'' for %s axes in ...programs/plot/plotsetupaxes (locSetFigPos) yet',rc);
   error(strMsg);
end
figScreenPos=[figScreenX figScreenY figScreenW figScreenH];
set(hFig,'units','pixels');
set(hFig,'position',figScreenPos);

figScreenPos=[figPaperX figPaperY figPaperW figPaperH];
set(hFig,'units','inches');
set(hFig,'paperposition',figScreenPos);

