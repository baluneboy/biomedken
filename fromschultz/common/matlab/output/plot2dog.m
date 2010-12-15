function h=plotwithtext(x,y,cas,strXType,strXUnits,strYType,strYUnits,casUL,casUR,strComment,strTitle,strVersion,casSides);

%PLOTWITHTEXT - plot xy with side text
%
%h=plotwithtext(x,y,cas,strXType,strXUnits,strYType,strYUnits,casUL,casUR,strComment,strTitle,strVersion,casSides);
%
%Inputs: h - structure of handles
%        x - N-element vector for xdata
%        y - N-element vector for 1x1 plot of ydata or
%            Nx3 matrix for 3x1 plots
%        cas - cell array of strings for ylabel(s) (like {'Y-Axis'}) or
%              {'X-Axis','Y-Axis','Z-Axis'}
%        strXType - string for ytype (like 'Acceleration')
%        strXUnits - string for yunits (like 'g')
%        strYType - string for ytype (like 'Acceleration')
%        strYUnits - string for yunits (like 'g')
%        casUL - cell array of strings for upper left text (max of 5)
%        casUR - cell array of strings for upper right text (max of 5)
%        strComment - string for comment at top
%        strTitle - string for title of top axes (usually 'Start <TimeBase> <StartTime>')
%        strVersion - version control string
%        casSides - cell array of strings for rotated, rightside text
%
%Outputs: h - structure of handles

%Author: Ken Hrovat, 1/20/2001
% $Id: plot2dog.m 4160 2009-12-11 19:10:14Z khrovat $

% Get dummy inputs for template show and tell
if nargin==0
   [x,y,cas,strXType,strXUnits,strYType,strYUnits,casUL,casUR,strComment,...
         strTitle,strVersion,casSides]=locDummyInputs;
   h.handles1x1=plotwithtext(x,y(:,1),cas,strXType,strXUnits,strYType,strYUnits,...
      casUL,casUR,strComment,strTitle,strVersion,casSides);
   h.handles3x1=plotwithtext(x,y,cas,strXType,strXUnits,strYType,strYUnits,...
      casUL,casUR,strComment,strTitle,strVersion,casSides);
   return
end

% Determine if 1x1 or 3x1 plot
numy=size(y,2);
if ~(numy==1 | numy==3)
   strErr=sprintf('expected either 1 or 3 columns for ydata, not %d',numy);
   error(strErr)
end

% Figure layout
posFig=getfigpos; %screen position
strFigTag=sprintf('Figure%dx1',numy);
hFig=figure(...
   'Color',[1 1 1],...
   'Position',posFig,...
   'Tag',strFigTag);

% Gather xdata settings
xmin=min(x);
xmax=max(x);

% Subplot-dependent settings
if numy==1
   set(hFig,...
      'PaperOrientation','landscape',...
      'PaperPosition',[0.25 0.25 10.5 8]);
   % Upper text position settings
   xposTextUR=1.1;
   xposTextUL=-0.1;
   yposTextOffset=1.08;
   yposTextDelta=0.02;
   % Comment position
   posTextComment=[0.5 1.08 0];
   % Gather ydata settings
   ymin=min(y);
   ymax=max(y);
else
   set(hFig,...
      'PaperOrientation','portrait',...
      'PaperPosition',[0.25 0.25 8 10.5]);
   % Upper text position settings
   xposTextUR=1.05;
   xposTextUL=-0.08;
   yposTextOffset=1.38;
   yposTextDelta=0.06;
   % Comment position
   posTextComment=[0.5 1.26 0];
   % Gather ydata settings
   ymin=min(min(y));
   ymax=max(max(y));
end
h=struct(strFigTag,hFig);

% Plot lines
h.AxesALL=[];
for r=numy:-1:1
   
   % RowCol identifier
   strSuffix=sprintf('%d1',r);
   
   % Plot line
   subplot(numy,1,r)
   hLine=plot(x,y(:,r),'k-');
   
   % Tag line
   strLineTag=['Line' strSuffix];
   set(hLine,'tag',strLineTag);
   
   % Add line to handle structure
   h=setfield(h,strLineTag,hLine);
   
   % Set some axes props
   hAxes=get(hLine,'Parent');
   posAxes=locGetAxPos(numy,r);
   set(hAxes,...
      'FontName','times',...
      'Position',posAxes,...
      'Tag',['Axes' strSuffix],...
      'TickDir','out');
   h.AxesALL=[h.AxesALL; hAxes];
   
   % Insert YLabel
   hy=ylabel(sprintf('%s %s (%s)',cas{r},strYType,strYUnits));
   strYLabelTag=['TextYLabel' strSuffix];
   h=setfield(h,strYLabelTag,hy);
   
   % Layout parameters for right side text (this for leftmost, rotated, axes-hugging text)
   posTextSideBot=[1.04 0 0];
   deltaTextSidePos=0.02;
   
   % Insert right-side, rotated, axis-hugging text
   if ( ~isempty(casSides) & length(casSides)>=r )
      casSide=casSides{r};
      hts=[];
      for iSide=length(casSide):-1:1
         strSideTag=sprintf('TextSide%s%d',strSuffix,iSide);
         strText=casSide{iSide};
         hTextSide = text(...
            'Parent',hAxes, ...
            'Units','normalized', ...
            'FontName','times', ...
            'FontSize',9, ...
            'Position',posTextSideBot, ...
            'Rotation',90, ...
            'String',strText, ...
            'Tag',strSideTag, ...
            'VerticalAlignment','top');
         h=setfield(h,strSideTag,hTextSide);
         hts=[hts; hTextSide];
         posTextSideBot=posTextSideBot-[deltaTextSidePos 0 0];
      end
      if isfield(h,'TextALLSide')
         hOld=getfield(h,'TextALLSide');
      else
         hOld=[];
      end
      h=setfield(h,'TextALLSide',[hOld; hts]);
   end
   
   % If bottom axes, then add XLabel & Version
   if r==numy
      h.TextXLabel=xlabel(sprintf('%s (%s)',strXType,strXUnits));
      if ~isempty(strVersion)
         h.TextVersion = text(...
            'Parent',hAxes, ...
            'Units','normalized', ...
            'Color',[0 0 0], ...
            'FontName','times', ...
            'FontSize',4, ...
            'HorizontalAlignment','right', ...
            'Position',[1.05 -0.05 0],...
            'String',strVersion, ...
            'Tag','TextVersion');
      end
   else
      set(hAxes,'XTickLabel',[]);
   end
   
   % If top axes, then add Title & Upper text
   if r==1
      % Title
      h.TextTitle=title(strTitle); set(h.TextTitle,'tag','TextTitle');
      % Comment
      if ~isempty(strComment)
         h.TextComment = text(...
            'Parent',hAxes, ...
            'Units','normalized', ...
            'FontName','times', ...
            'HorizontalAlignment','center', ...
            'Position',posTextComment, ...
            'String',strComment, ...
            'Tag','TextComment');
      end
      % Note: right then left & last to first for property inspector top to bottom
      if ~isempty(casUR)
         % TextUR (Upper Right)
         for i=length(casUR):-1:1
            h=locTextUpper(hAxes,i,h,xposTextUR,yposTextOffset,yposTextDelta,casUR);
         end
      end
      % TextUL (Upper Left)
      if ~isempty(casUL)
         for i=length(casUL):-1:1
            h=locTextUpper(hAxes,i,h,xposTextUL,yposTextOffset,yposTextDelta,casUL);
         end
      end
   end
   
end

% Set axes limits
set(h.AxesALL,'xlim',[xmin xmax]);
set(h.AxesALL,'ylim',[ymin ymax]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function posAxes=locGetAxPos(numy,r);
if numy==1
   posAxesY=0.07;
   posAxesH=0.77;
else
   posAxesY=0.07+0.29*(3-r);
   posAxesH=0.24;
end
posAxes=[0.12 posAxesY 0.81 posAxesH];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=locTextUpper(hAxes,i,h,posX,yposTextOffset,yposTextDelta,casUpper);

posY=yposTextOffset+(1-i)*yposTextDelta;
if posX<0.5
   strSide='Left';
else
   strSide='Right';
end

% Row identifier
strTextTag=sprintf('TextUpper%s%d',strSide,i);

hText=text(...
   'Parent',hAxes, ...
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
function [x,y,cas,strXType,strXUnits,strYType,strYUnits,casUL,casUR,strComment,strTitle,strVersion,casSides]=locDummyInputs;
[x,y]=humps(0:5e-3:1);x=x(:);y=y(:);
y=[y 0.1*y -y];
cas={'cas{1}','cas{2}','cas{3}'};
strXType='strXType';
strXUnits='strXUnits';
strYType='strYType';
strYUnits='strYUnits';
casUL={'casUL{1}','casUL{2}','12345678901234567890','casUL{4}','casUL{5}'};
casUR={'casUR{1}','casUR{2}','09876543210987654321','casUR{4}','casUR{5}'};
strComment='strComment';
strTitle='strTitle';
strVersion='strVersion';
casSides={{'casSides{1}{1}','casSides{1}{2}'};{'casSides{2}{1}','casSides{2}{2}'};{'casSides{3}{1}','casSides{3}{2}'}};
