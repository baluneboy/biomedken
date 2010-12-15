function [hFig,hAx,hAxTitle,hAxXLabel]=plotsetupfigax(rows,cols);

%PLOTSETUPFIGAX - function to initialize figure & axes (positions, units, etc.).
%
%[hFig,hAx,hAxTitle,hAxXLabel]=plotsetupfigax(rows,cols);
%
%Inputs: rows - scalar number of axes rows
%        cols - scalar number of axes cols
%
%Output: hFig - scalar handle of figure parent
%        hAx - matrix of axes handles
%        hAxTitle - scalar handle for axes parent of ancillary text
%        hAxXLabel - scalar handle for axes parent of xlabel

% written by: Ken Hrovat on 7/7/2000
% $Id: plotsetupfigax.m 4160 2009-12-11 19:10:14Z khrovat $

% Initialize figure
hFig=figure;
clf;
set(hFig,'color','w');

% Get width & height of screen in pixels
[screenWidth,screenHeight]=locGetScreenSize; %pixels

% Create axes & set some props
hAx=locCreateAxes(rows,cols);
set(hAx,'tickdir','out','fontname','times','box','on');

% Branch to specific layout to set figure & axes positions
rc=sprintf('%d-by-%d',rows,cols);
switch rc
case '3-by-1' % portrait
   FUDGE=0.925;
   % Set lower-left corner of figure
   figScreenX=222;    figScreenY=35;		% on screen (pixels)
   figPaperX=0.25;   figPaperY=1.25;	% on paper (inches)
   % Set some axes positions in pixels
   axX=85; axY=73; %lower-left corner of lower-leftmost axes   
   % Figure props
   orient(hFig,'tall');
   figScreenW=FUDGE*(8.5/11)*(screenHeight-figScreenY);
   figScreenH=FUDGE*(screenHeight-figScreenY);
   figPaperW= 8.00;
   figPaperH=10.50;
   % Axes props
   set(hAx,'units','pixels');
   axW=577; axH=233; %width and height of each axes (in pixels)
  	dY=262; %delta Y position in pixels
   set(hAx(3,1),'position',[axX axY       axW axH]);   
   set(hAx(2,1),'position',[axX axY+dY    axW axH]);
   set(hAx(1,1),'position',[axX axY+2*dY  axW axH]);
   % Set special handle axes
   hAxTitle=hAx(1,1);
   hAxXLabel=hAx(3,1);
case '1-by-1' % landscape
   FUDGE=0.99;
   % Set lower-left corner of figure
   figScreenX=77;    figScreenY=35;		% on screen (pixels)
   figPaperX=0.25;   figPaperY=1.25;	% on paper (inches)
   % Set some axes positions in pixels
   axX=111; axY=73; %lower-left corner of lower-leftmost axes
   % Figure props
   orient(hFig,'landscape');
   figScreenW=FUDGE*(screenWidth-figScreenX);
   figScreenH=FUDGE*(8.5/11)*(screenWidth-figScreenX);
   figPaperW=10.50;   
   figPaperH= 8.00;
   % Axes props
   set(hAx,'units','pixels');
   axW=0.83*figScreenW; axH=0.83*figScreenH; %width and height of each axes (in pixels)
   dY=262; %delta Y position in pixels
   set(hAx(1,1),'position',[axX axY axW axH]);
   % Set special handle axes
   hAxTitle=hAx(1,1);
   hAxXLabel=hAx(1,1);
otherwise
   strMsg=sprintf('no ''case'' for %s axes in ...programs/plot/plotsetupaxes (locSetFigAx) yet',rc);
   error(strMsg);
end
figScreenPos=round([figScreenX figScreenY figScreenW figScreenH]);
set(hFig,'units','pixels');
set(hFig,'position',figScreenPos);
figPaperPos=[figPaperX figPaperY figPaperW figPaperH];
set(hFig,'paperunits','inches');
set(hFig,'paperposition',figPaperPos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pixwidth,pixheight]=locGetScreenSize;
xywh=get(0,'screensize');
pixwidth=xywh(3);
pixheight=xywh(4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hAx=locCreateAxes(rows,cols);
hAx=zeros(rows,cols);
count=1;
% Reverse order for user-friendlier handle assignment
for m=rows:-1:1
   for n=cols:-1:1
      hAx(m,n)=subplot(rows,cols,count);
      count=count+1;
   end
end
xticklabel=get(hAx(rows,1),'XTickLabel');
set(hAx,'XTickLabel',[]);
set(hAx(rows,:),'XTickLabel',xticklabel);
