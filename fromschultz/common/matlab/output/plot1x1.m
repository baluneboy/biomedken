function h=plot1x1(data,str,strXType,strXUnits,strYType,strYUnits,casUL,casUR,strComment,strTitle,strVersion,casSide);

%plot1x1 - generic 1-panel landscape plot routine
%
%h=plot1x1(data,str,strXType,strXUnits,strYType,strYUnits,casUL,casUR,strComment,strTitle,strVersion,casSide);
%or
%h=plot1x1; % for template
%
%Inputs: data - matrix of [x y]
%        str - string for ylabeling like 'Vector Magnitude'
%        strXType - string for x-type (like 'Time')
%        strXUnits - string for x-units (like 'seconds')
%        strYType - string for y-type (like 'Acceleration')
%        strYUnits - string for y-units (like 'g')
%        casUL - cell array of strings for upper left text (max of 5)
%        casUR - cell array of strings for upper right text (max of 5)
%        strComment - string for comment at top
%        strTitle - string for title of top axes (usually 'Start <TimeBase> <StartTime>')
%        strVersion - version control string
%        casSide - cell array of strings for right side, rotated, axes-hugging text (max 2)
%
%Outputs: h - structure of handles

%Author: Ken Hrovat, 1/19/2001
% $Id: plot1x1.m 4160 2009-12-11 19:10:14Z khrovat $

% Get dummy inputs for template show and tell
if nargin==0
   [data,str,strXType,strXUnits,strYType,strYUnits,casUL,casUR,strComment,...
         strTitle,strVersion,casSide]=locDummyInputs;
end

% Gather axis settings
xmin=min(data(:,1));
xmax=max(data(:,1));
ymin=min(data(:,2));
ymax=max(data(:,2));

% Figure layout
posFig=getfigpos; %screen position
h.Figure1x1 = figure(...
   'Color',[1 1 1],...
   'PaperOrientation','landscape',...
   'PaperPosition',[0.25 0.25 10.5 8], ...
   'Position',posFig,...
   'Tag','Figure1x1');

% Axes, line, and side text
h=locAxesLineText(h,data(:,1),data(:,2),str,strYType,strYUnits,casSide);

% XLabel
h.TextXLabel=xlabel(sprintf('%s (%s)',strXType,strXUnits));
if ~isempty(strVersion)
   h.TextVersion = text('Parent',h.Axes, ...
      'Units','normalized', ...
      'Color',[0 0 0], ...
      'FontName','times', ...
      'FontSize',4, ...
      'HorizontalAlignment','right', ...
      'Position',[1.05 -0.1 0], ...
      'String',strVersion, ...
      'Tag','TextVersion');
end

% Title
h.TextTitle=title(strTitle); set(h.TextTitle,'tag','TextTitle');

% Comment
if ~isempty(strComment)
   h.TextComment = text('Parent',h.Axes, ...
      'Units','normalized', ...
      'FontName','times', ...
      'HorizontalAlignment','center', ...
      'Position',[0.5 1.08 0], ...
      'String',strComment, ...
      'Tag','TextComment');
end

% Note: right then left & last to first for property inspector top to bottom
if ~isempty(casUR)
   % TextUR (Upper Right)
   xposTextUR=1.1;
   for i=length(casUR):-1:1
      h=locTextUpper(i,h,xposTextUR,casUR);
   end
end

% TextUL (Upper Left)
if ~isempty(casUL)
   xposTextUL=-0.1;
   for i=length(casUL):-1:1
      h=locTextUpper(i,h,xposTextUL,casUL);
   end
end

% Need smarter setxlim function
set(h.Axes,'xlim',[xmin xmax]);

% Need smarter setylim function
set(h.Axes,'ylim',[ymin ymax]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=locAxesLineText(h,x,y,str,strYType,strYUnits,casSide);

% Plot the line
h.Line=plot(x,y,'k-');
set(h.Line,'Tag','Line');

% Set some axes props
h.Axes=get(h.Line,'Parent');
set(h.Axes,...
   'FontName','times',...
   'Tag','Axes',...
   'TickDir','out');

% Insert YLabel
h.TextYLabel=ylabel(sprintf('%s %s (%s)',str,strYType,strYUnits));

% Layout parameters for right side text (this for leftmost, rotated, axes-hugging text)
posTextSideOne=[1.03 0 0];
deltaTextSidePos=-0.02;

% Insert right-side, rotated, axis-hugging text
if ~isempty(casSide)
   hts=[];
   for iSide=length(casSide):-1:1
      strSideTag=sprintf('TextSide%d',iSide);
      strText=casSide{iSide};
      hTextSide = text(...
         'Parent',h.Axes, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=locTextUpper(i,h,posX,casUpper);

dyTextUpper=0.02;
posY=1.08+(1-i)*dyTextUpper;
if posX<0.5
   strSide='Left';
else
   strSide='Right';
end

% Row identifier
strTextTag=sprintf('TextUpper%s%d',strSide,i);

hText=text(...
   'Parent',h.Axes, ...
   'Units','normalized', ...
	'FontName','times', ...
	'FontSize',7, ...
	'HorizontalAlignment',strSide, ...
	'Position',[posX posY 0], ...
	'String',casUpper{i}, ...
   'Tag',strTextTag);
h=setfield(h,strTextTag,hText);

if isfield(h,'TextALLUpper')
   hOld=getfield(h,'TextALLUpper');
else
   hOld=[];
end
h.TextALLUpper=[hOld; hText];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,str,strXType,strXUnits,strYType,strYUnits,casUL,casUR,strComment,strTitle,strVersion,casSide]=locDummyInputs;
[x,y]=humps(0:5e-3:1);x=x(:);y=y(:);
data=[x y];
str='str';
strXType='strXType';
strXUnits='strXUnits';
strYType='strYType';
strYUnits='strYUnits';
casUL={'casUL{1}','casUL{2}','12345678901234567890','casUL{4}','casUL{5}'};
casUR={'casUR{1}','casUR{2}','09876543210987654321','casUR{4}','casUR{5}'};
strComment='strComment';
strTitle='strTitle';
strVersion='strVersion';
casSide={'casSide{1}','casSide{2}'};
