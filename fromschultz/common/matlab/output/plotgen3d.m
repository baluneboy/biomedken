function h=plotgen3d(x,y,z,sText,strOutType,sReport);

%plotgen3d - plot generic 2d (xyz) with side text and optionally
%            report title, figure #, figure caption, page #, and
%            left- or right-facing
%
%h=plotgen3d(x,y,z,sText,strOutType,sReport);
%
%Inputs: x - N-element vector for xdata
%        y - M-element vector for ydata
%        z - M-by-N-element vector for zdata (if 1x1) or
%            M-by-N-by-3 element matrix for zdata (if 3x1)
%        sText - structure of text with fields 
%           .strXType - string for common (like 'Time')
%           .strYType - string for common (like 'Frequency')
%           .strXUnits - string for common (like 'seconds')
%           .strYUnits - string for common (like 'Hz')
%           .casYStub - cas for ylabel(s) (like {'Sum'}) or
%                 {'X-Axis','Y-Axis','Z-Axis'}
%           .casYUnits - cas for common (like {'seconds'}) or multi like
%                  {'m/s^2','m/s','m'}
%           .casUL - cell array of strings for upper left text
%           .casUR - cell array of strings for upper right text
%           .strComment - string for comment
%           .strTitle - string for title of top axes
%           .strVersion - string for offline version control
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
% $Id: plotgen3d.m 4160 2009-12-11 19:10:14Z khrovat $

% Temp for quick look
sHeader=sText.sTEMPheader;
sPlot=sText.sTEMPplot;
fs=sHeader.SampleRate;
fc=sHeader.CutoffFreq;
timechoice=sPlot.TUnits;
timestartstr=popdatestr(sHeader.sdnDataStart,0);
head=[sHeader.DataType ', ' sHeader.SensorID];
mission=sText.casUR{1};
coord=sText.casUR{2};
ttl=sText.strComment;
strWhichAx=sPlot.WhichAx;
strWin=sPlot.Window;
window=sText.TEMPwindow;
Nfft=sPlot.Nfft;
No=sPlot.No;
strColormap=sPlot.Colormap;
maxf=sPlot.FLim(2);
clim=sPlot.CLim;
fig=figure;

if ndims(z)==3
   disp('need to do')
   return
   [textt,hmetstart,anch,ax1,ax2,ax3,cax1,cax2,cax3]=plot_3spec(...
      t,x,y,z,fcstr,fsstr,timechoice,timestartstr,head,mission,...
      coord,ttl,windchoice,strWin,Nfft,No,strColormap,maxf,clim,fig);
else
   [textt,hmetstart,cblabel,anch,ax1,cax1]=plot1spec(x,y,z,fc,fs,...
      timechoice,timestartstr,head,mission,coord,ttl,...
      strWhichAx,window,strWin,Nfft,No,strColormap,maxf,clim,fig);
end

return

% Get dummy inputs for template show and tell
if nargin==0
   %[x,y,sText,sReport]=locDummyInputs;
   %h.p1x1=plotgen3d(x,y(:,1),sText,[]);
   [x,y,sText,sReport]=locDummyInputs;
   h.p3x1=plotgen3d(x,y,sText,[]);
   return
end

% Get subplot/report-dependent settings
[sTextPosition,sFigure,numy,ymin,ymax]=locFigTextSettings(y,sReport);

% Figure layout
sFigure.Position=getdeffigpos(sFigure.PaperOrientation); %screen position
sFigure.Tag=sprintf('Figure%dx1',numy);
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
   strAxesTag=['Axes' strSuffix];
   posAxes=getdefaxpos2d(numy,r,sReport,strOutType); %axes position [x y w h]
   set(hAxes,...
      'FontName','times',...
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
            'FontName','times', ...
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
   if r==numy
      h.TextXLabel=xlabel(sprintf('%s (%s)',sText.strXType,sText.strXUnits));
      if ~isempty(sText.strVersion)
         h.TextVersion = text(...
            'Parent',hAxes, ...
            'Units','normalized', ...
            'Color',[0 0 0], ...
            'FontName','times', ...
            'FontSize',4, ...
            'HorizontalAlignment','right', ...
            'Position',sTextPosition.xyzVersion,...
            'String',sText.strVersion, ...
            'Tag','TextVersion');
      end
   else
      set(hAxes,'XTickLabel',[]);
   end
   
   % If top axes, then add Title & Upper text
   if r==1
      % Title
      h.TextTitle=title(sText.strTitle); set(h.TextTitle,'tag','TextTitle');
      % Comment
      if ~isempty(sText.strComment)
         h.TextComment = text(...
            'Parent',hAxes, ...
            'Units','normalized', ...
            'FontName','times', ...
            'HorizontalAlignment','center', ...
            'Position',sTextPosition.xyzComment, ...
            'String',sText.strComment, ...
            'Tag','TextComment');
      end
      % Note: right then left & last to first for property inspector top to bottom
      if ~isempty(sText.casUR)
         % TextUR (Upper Right)
         for i=length(sText.casUR):-1:1
            h=locTextUpper(hAxes,i,h,sTextPosition.xUR,sTextPosition,sText.casUR);
         end
      end
      % TextUL (Upper Left)
      if ~isempty(sText.casUL)
         for i=length(sText.casUL):-1:1
            h=locTextUpper(hAxes,i,h,sTextPosition.xUL,sTextPosition,sText.casUL);
         end
      end
   end
   
end

% Set axes limits
set(h.AxesALL,'xlim',[xmin xmax]);
set(h.AxesALL,'ylim',[ymin ymax]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sTextPosition,sFigure,numy,ymin,ymax]=locFigTextSettings(y,sReport);

% Determine if 1x1 or 3x1 plot
numy=size(y,2);
if ~(numy==1 | numy==3)
   strErr=sprintf('expected either 1 or 3 columns for ydata, not %d',numy);
   error(strErr)
end

% Subplot-dependent settings
if numy==1 %1x1
   % Figure settings
   sFigure.PaperOrientation='landscape';
   sFigure.PaperPosition=[0.25 0.25 10.5 8];
   % Upper text position settings
   sTextPosition.xUR=1.05;
   sTextPosition.xUL=-0.05;
   sTextPosition.yUtop=1.08;
   sTextPosition.yDelta=0.02;
   % Comment and version
   sTextPosition.xyzComment=[0.5   1.06 0];
   sTextPosition.xyzVersion=[1.05 -0.05 0];
   % Gather ydata settings
   ymin=min(y);
   ymax=max(y);
else %3x1
   % Figure settings
   sFigure.PaperOrientation='portrait';
   sFigure.PaperPosition=[0.25 0.25 8 10.5];
   % Upper text position settings
   sTextPosition.xUR=1.05;
   sTextPosition.xUL=-0.08;
   sTextPosition.yUtop=1.34;
   sTextPosition.yDelta=0.05;
   % Comment and version
   sTextPosition.xyzComment=[0.5   1.28 0];
   sTextPosition.xyzVersion=[1.05 -0.10 0];
   % Gather ydata settings
   ymin=min(min(y));
   ymax=max(max(y));
end

% Layout parameters for right side text (this for leftmost, rotated, axes-hugging text)
sTextPosition.xyzRSbottom=[1.04 0 0];
sTextPosition.xRSdelta=0.02;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y,sText,sReport]=locDummyInputs;
[x,y]=humps(0:5e-3:1);x=x(:);y=y(:);
y=[y 0.1*y -y];
sText.strXType='strXType';
sText.strXUnits='strXUnits';
sText.casYStub={'ystub1','ystub2','ystub3'};
sText.casYTypes='YType';
sText.casYUnits='YUnits';
sText.casUL={'UpLeft{1}','UpLeft{2}','12345678901234567890','UpLeft{4}'};
sText.casUR={'UpRight{1}','UpRight{2}','09876543210987654321','UpRight{4}'};
sText.strComment='This is sText.strComment';
sText.strTitle='sText.strTitle';
sText.strVersion='sText.strVersion';
sText.casRS={{'RightSide{1}{1}','RightSide{1}{2}'};{'RightSide{2}{1}','RightSide{2}{2}'};{'RightSide{3}{1}','RightSide{3}{2}'}};
sReport.strTitle='This is sReport.strTitle';
sReport.numPage=432;
sReport.numFig=99;
sReport.strCaption='This is sReport.strCaption';