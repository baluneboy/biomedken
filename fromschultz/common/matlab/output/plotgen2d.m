function h=plotgen2d(x,y,sText,strOutType,sReport);

%plotgen2d - plot generic 2d (xy) with side text and optionally
%            report title, figure #, figure caption, page #, and
%            left- or right-facing
%
%h=plotgen2d(x,y,sText,strOutType,sReport);
%
%Inputs: x - N-element vector for xdata
%        y - N-element vector for ydata (if 1x1) or
%            Nx3 element matrix for ydata (if 3x1)
%        sText - structure of text with fields 
%           .strXType - string for common (like 'Time')
%           .strXUnits - string for common (like 'seconds')
%           .casYStub - cas for ylabel(s) (like {'Vector Magnitude'}) or
%                 {'X-Axis','Y-Axis','Z-Axis'}
%           .casYTypes - cas for common (like {'Acceleration'}) or multi like
%                  {'Acceleration','Velocity','Displacement'}
%           .casYUnits - cas for common (like {'seconds'}) or multi like
%                  {'m/s^2','m/s','m'}
%           .casUL - cell array of strings for upper left text
%           .casUR - cell array of strings for upper right text
%           .strComment - string for comment
%           .strTitle - string for title of top axes
%           .casRS - cell array of strings for rotated, rightside text
%        strOutType - string for output type
%        sReport - structure of report text with fields 
%           .strTitle - string for report title at top
%           .numPage - scalar for page number in caption at bottom
%           .numFig - scalar for figure number in caption
%           .strCaption - string for figure caption
%
%Outputs: h - structure of handles

%Author: Ken Hrovat, 1/20/2001
% $Id: plotgen2d.m 4160 2009-12-11 19:10:14Z khrovat $

% Get dummy inputs for template show and tell
if nargin==0
   %[x,y,sText,sReport]=locDummyInputs;
   %h.p1x1=plotgen2d(x,y(:,1),sText,[]);
   [x,y,sText,sReport]=locDummyInputs;
   h.p3x1=plotgen2d(x,y,sText,'screen',[]);
   return
end

% Get subplot/report-dependent settings
numAx=size(y,2);
[sTextPosition,sFigure]=figtextsettings(numAx,sReport);
ymin=min(y(:));
ymax=max(y(:));

% Figure layout
sFigure.Position=getdeffigpos(sFigure.PaperOrientation); %screen position
sFigure.Tag=sprintf('Figure%dx1',numAx);
hFig=figure(...
   'Color',[1 1 1],...
   'PaperOrientation',sFigure.PaperOrientation,...
   'PaperPosition',sFigure.PaperPosition,...
   'Position',sFigure.Position,...
   'Tag',sFigure.Tag);
h=struct(sFigure.Tag,hFig);

% Gather xdata settings
xmin=min(x);
xmax=max(x);

% Plot lines
h.AxesALL=[];
h.LineALL=[];
for r=numAx:-1:1
   
   % RowCol identifier
   strSuffix=sprintf('%d1',r);
   
   % Plot line
   subplot(numAx,1,r)
   hLine=plot(x,y(:,r),'k-');
   h.LineALL=[h.LineALL; hLine];
   
   % Tag line
   strLineTag=['Line' strSuffix];
   set(hLine,'tag',strLineTag);
   
   % Add line to handle structure
   h=setfield(h,strLineTag,hLine);
   
   % Set some axes props
   hAxes=get(hLine,'Parent');
   strAxesTag=['Axes' strSuffix];
   posAxes=getdefaxpos2d(numAx,r,sReport,strOutType); %axes position [x y w h]
   set(hAxes,...
      'FontName','Helvetica',...
      'Position',posAxes,...
      'Tag',strAxesTag,...
      'TickDir','out');
   h=setfield(h,strAxesTag,hAxes);
   h.AxesALL=[h.AxesALL; hAxes];
   
   % Insert YLabel
   hy=ylabel(sprintf('%s %s (%s)',sText.casYStub{r},sText.casYTypes{r},sText.casYUnits{r}));
   strYLabelTag=['TextYLabel' strSuffix];
   h=setfield(h,strYLabelTag,hy);
   
   % Insert right-side, rotated, axis-hugging text
   if ( ~isempty(sText.casRS) & length(sText.casRS)>=r )
      casSide=sText.casRS{r};
      hts=[];
      posRStext=sTextPosition.xyzRSbottom;
      for iSide=length(casSide):-1:1
         strSideTag=sprintf('TextSide%s%d',strSuffix,iSide);
         strText=casSide{iSide};
         hTextSide = text(...
            'Parent',hAxes, ...
            'Units','normalized', ...
            'FontName','Helvetica', ...
            'FontSize',9, ...
            'Position',posRStext, ...
            'Rotation',90, ...
            'String',strText, ...
            'Tag',strSideTag, ...
            'VerticalAlignment','top');
         h=setfield(h,strSideTag,hTextSide);
         hts=[hts; hTextSide];
         posRStext=posRStext-[sTextPosition.xRSdelta 0 0];
      end
      if isfield(h,'TextALLSide')
         hOld=getfield(h,'TextALLSide');
      else
         hOld=[];
      end
      h=setfield(h,'TextALLSide',[hOld; hts]);
   end
   
   % If bottom axes, then add XLabel & Version
   if r==numAx
      h=bottomxlabtext(h,hAxes,sTextPosition.xyzVersion,sText);
   else
      set(hAxes,'XTickLabel',[]);
   end
   
   % If top axes, then add Title & Upper text
   if r==1
      h=uppertitletext(h,hAxes,sTextPosition,sFigure,sText);
   end
   
end

% Set axes limits
set(h.AxesALL,'xlim',[xmin xmax]);
set(h.AxesALL,'ylim',[ymin ymax]);

% Nudge YLabels left where there's RMS subscript
nudgesubscript(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=locTextUpper(hAxes,i,h,posX,sTextPosition,casUpper);

yUtop=sTextPosition.yUtop;
yDelta=sTextPosition.yDelta;

posY=yUtop+(1-i)*yDelta;
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
   'FontName','Helvetica', ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y,sText,sReport]=locDummyInputs;
[x,y]=humps(0:5e-3:1);x=x(:);y=y(:);
y=[y 0.1*y -y];
sText.strXType='strXType';
sText.strXUnits='strXUnits';
sText.casYStub={'ystub1','ystub2','ystub3'};
sText.casYTypes={'ytype1','ytype2','ytype3'};
sText.casYUnits={'yunits1','yunits2','yunits3'};
sText.casUL={'UpLeft{1}','UpLeft{2}','12345678901234567890','UpLeft{4}'};
sText.casUR={'UpRight{1}','UpRight{2}','09876543210987654321','UpRight{4}'};
sText.strComment='This is sText.strComment';
sText.strTitle='sText.strTitle';
sText.casRS={{'RightSide{1}{1}','RightSide{1}{2}'};{'RightSide{2}{1}','RightSide{2}{2}'};{'RightSide{3}{1}','RightSide{3}{2}'}};
sReport.strTitle='This is sReport.strTitle';
sReport.numPage=432;
sReport.numFig=99;
sReport.strCaption='This is sReport.strCaption';
