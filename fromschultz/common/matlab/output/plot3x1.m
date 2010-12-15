function h=plot3x1(varargin);

%PLOT3x1 - generic 3-panel plot routine
%
%h=plot3x1(data,cas,strXType,strXUnits,strYType,strYUnits,casUL,casUR,strComment,strTitle,strVersion,casSides);
%or
%h=plot3x1; % for template
%
%Inputs: data - matrix of [x yTop yMiddle yBottom]
%        cas - cell array of strings for ylabeling {'X-Axis','Y-Axis','Z-Axis'}
%        strXType - string for x-type (like 'Time')
%        strXUnits - string for x-units (like 'seconds')
%        strYType - string for y-type (like 'Acceleration')
%        strYUnits - string for y-units (like 'g')
%        casUL - cell array of strings for upper left text (max of 5)
%        casUR - cell array of strings for upper right text (max of 5)
%        strComment - string for comment at top
%        strTitle - string for title of top axes (usually 'Start <TimeBase> <StartTime>')
%        strVersion - version control string
%        casSides - cell array of strings for right side, rotated, axes-hugging text (max 2)
%                   casSides{1} for Axes11
%                   casSides{2} for Axes21
%                   casSides{3} for Axes31
%
%Outputs: h - structure of handles

%Author: Ken Hrovat, 1/18/2001
% $Id: plot3x1.m 4160 2009-12-11 19:10:14Z khrovat $

if nargin==0;
   [x,y]=humps(0:5e-3:1);x=x(:);y=y(:);
   data=[x y 1e-6*y -y];
   cas={'cas{1}','cas{2}','cas{3}'};
   strXType='strXType';
   strXUnits='strXUnits';
   strYType='strYType';
   strYUnits='strYUnits';
   casUL={'casUL{1}','casUL{2}','casUL{3}','casUL{4}','casUL{5}'};
   casUR={'casUR{1}','casUR{2}','casUR{3}','casUR{4}','casUR{5}'};
   strComment='strComment';
   strTitle='strTitle';
   strVersion='strVersion';
   casSides={{'casSides{1}{1}','casSides{1}{2}'};{'casSides{2}{1}','casSides{2}{2}'};{'casSides{3}{1}','casSides{3}{2}'}};
else
   [data,cas,strXType,strXUnits,strYType,strYUnits,casUL,casUR,strComment,strTitle,strVersion,casSides]=deal(varargin{:});
end

% Gather axis settings
xmin=min(data(:,1));
xmax=max(data(:,1));
ymin=min(min(data(:,2:end)));
ymax=max(max(data(:,2:end)));

% Figure layout
h.Figure = figure('Color',[1 1 1], ...
	'PaperPosition',[18 9 576 756], ...
	'PaperUnits','points', ...
	'Position',[69 9 765 960], ...
	'ResizeFcn','doresize(gcbf)', ...
	'Tag','Figure3x1', ...
	'ToolBar','figure', ...
   'DefaultaxesCreateFcn','plotedit(gcbf,''promoteoverlay'');');

% Start with bottom and work up (for backwards MATLAB handle issue)
% Axes31
h=locAxesLineText(3,h,data(:,1),data(:,4),cas,strYType,strYUnits,casSides);
h.TextXLabel31=xlabel(sprintf('%s (%s)',strXType,strXUnits));
h.TextVersion = text('Parent',h.Axes31, ...
	'Units','normalized', ...
	'Color',[0 0 0], ...
	'FontName','times', ...
	'FontSize',4, ...
	'HorizontalAlignment','right', ...
	'Position',[1.04 -0.17 0], ...
	'String',strVersion, ...
   'Tag','TextVersion');

% Axes21
h=locAxesLineText(2,h,data(:,1),data(:,3),cas,strYType,strYUnits,casSides);

% Axes11
h=locAxesLineText(1,h,data(:,1),data(:,2),cas,strYType,strYUnits,casSides);

% Title
h.TextTitle11=title(strTitle); set(h.TextTitle11,'tag','TextTitle11');

% Comment
h.TextComment = text('Parent',h.Axes11, ...
	'Units','normalized', ...
	'FontName','times', ...
	'HorizontalAlignment','center', ...
	'Position',[0.49597423510467 1.26 0], ...
	'String',strComment, ...
   'Tag','TextComment');

% TextUL (Upper Left)
posTextUL=-0.08;
for i=1:length(casUL)
   h=locTextUpper(i,h,posTextUL,casUL);
end

% TextUR (Upper Right)
posTextUR=1.05;
for i=1:length(casUR)
   h=locTextUpper(i,h,posTextUR,casUR);
end

% Need smarter setxlim function
set([h.Axes11 h.Axes21 h.Axes31],'xlim',[xmin xmax]);

% Need smarter setylim function
set([h.Axes11 h.Axes21 h.Axes31],'ylim',[ymin ymax]);

set([h.Axes11 h.Axes21 h.Axes31],'tickdir','out');

% Convenience handles
h.AxesALL=[h.Axes11; h.Axes21; h.Axes31];

% Tag axes last because of MATLAB funny
set(h.Axes11,'tag','Axes11');
set(h.Axes21,'tag','Axes21');
set(h.Axes31,'tag','Axes31');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=locAxesLineText(r,h,x,y,cas,strYType,strYUnits,casSides);

% Layout parameters for axes (only vertical positions are different)
posAxesX=0.1176470588235294;
posAxesY=0.06818181818181818+0.286363636363636*(3-r);
posAxesW=0.8117647058823529;
posAxesH=0.2409090909090909;
posAxes=[posAxesX posAxesY posAxesW posAxesH];

posAxesX=0.12;
posAxesY=0.07+0.29*(3-r);
posAxesW=0.81;
posAxesH=0.24;
posAxes=[posAxesX posAxesY posAxesW posAxesH];


% Layout parameters for right side text (this for leftmost, rotated, axes-hugging text)
posTextSideOne=[1.009057971014493   0.01882845188284519    0];
deltaTextSidePos=0.0209420289855071;

% Row-column sPosition identifier
strSuffix=sprintf('%d1',r);

% Generate the axes
strAxesTag=['Axes' strSuffix];
hAxes = axes('Parent',h.Figure, ...
	'FontName','times', ...
	'Position',posAxes, ...
	'Tag',strAxesTag, ...
   'TickDir','out');
h=setfield(h,strAxesTag,hAxes);

% Plot the line
hLine=plot(x,y,'k-');
strLineTag=['Line' strSuffix];
set(hLine,'Tag',strLineTag);
h=setfield(h,strLineTag,hLine);

% Insert YLabel
strYLabelTag=['TextYLabel' strSuffix];
hy=ylabel(sprintf('%s %s (%s)',cas{r},strYType,strYUnits));
h=setfield(h,strYLabelTag,hy);

% Insert right-side, rotated, axis-hugging text
if ( ~isempty(casSides) & length(casSides)>=r )
   casSide=casSides{r};
   hts=[];
   for iSide=1:length(casSide)
      strSideTag=sprintf('TextSide%s%d',strSuffix,iSide);
      strText=casSide{iSide};
      hTextSide = text('Parent',hAxes, ...
         'Units','normalized', ...
         'FontName','times', ...
         'FontSize',9, ...
         'Position',posTextSideOne, ...
         'Rotation',90, ...
         'String',strText, ...
         'Tag',strSideTag, ...
         'VerticalAlignment','top');
      h=setfield(h,strSideTag,hTextSide);
      hts=[hts; hTextSide];
      posTextSideOne=posTextSideOne+[deltaTextSidePos 0 0];
   end
   if isfield(h,'TextALLSide')
      hOld=getfield(h,'TextALLSide');
   else
      hOld=[];
   end
   h=setfield(h,'TextALLSide',[hOld; hts]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=locTextUpper(i,h,posX,casUR);

dyTextUpper=0.06;
posY=1.38+(1-i)*dyTextUpper;
if posX<0.5
   strSide='left';
else
   strSide='right';
end

% Row identifier
strTextTag=sprintf('TextUpper%s%d',strSide,i);

hText=text('Parent',h.Axes11, ...
	'Units','normalized', ...
	'FontName','times', ...
	'FontSize',7, ...
	'HorizontalAlignment',strSide, ...
	'Position',[posX posY 0], ...
	'String',casUR{i}, ...
   'Tag',strTextTag);
h=setfield(h,strTextTag,hText);

if isfield(h,'TextALLUpper')
   hOld=getfield(h,'TextALLUpper');
else
   hOld=[];
end
h.TextALLUpper=[hOld; hText];

   
