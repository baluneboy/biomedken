function sHandles=plotgenspec(t,f,b,sText,strOutType,sReport,flim,clim);

%plotgenspec - plot generic 2d (xy) with side text and optionally
%              report title, figure #, figure caption, page #, and
%              left- or right-facing
%
%sHandles=plotgenspec(t,f,b,sText,strOutType,sReport,fmax,clim);
%
%Inputs: t - vector of time
%        f - vector of frequency
%        b - matrix of PSD values (or matrices of PSDs)
%        sText - structure of text with fields 
%           .strXUnits - string for time units (like 'minutes')
%           .casYStub - cas for ylabel(s) (like {'Sum'}) or
%                 {'X-Axis','Y-Axis','Z-Axis'}
%           .casUL - cell array of strings for upper left text
%           .casUR - cell array of strings for upper right text
%           .strComment - string for comment
%           .strTitle - string for title of top axes
%           .strVersion - string for offline version control
%           .casRS - cell array of strings for rotated, rightside text
%           .strWindow - string for window function
%        strOutType - string for output type
%        sReport - structure of report text with fields 
%           .strTitle - string for report title at top
%           .numPage - scalar for page number in caption at bottom
%           .numFig - scalar for figure number in caption
%           .strCaption - string for figure caption
%        flim - frequency limits (like [0 fc])
%        clim - colorbar limits (like [-13 -6])
%
%Outputs: sHandles - structure of handles

%Author: Ken Hrovat, 1/20/2001
% $Id: plotgenspecnew.m 4160 2009-12-11 19:10:14Z khrovat $

% Get dummy inputs for template show and tell
if nargin==0
   %[x,y,sText,sReport]=locDummyInputs;
   %h.p1x1=plotgenspec(x,y(:,1),sText,[]);
   [x,y,sText,sReport]=locDummyInputs;
   h.p3x1=plotgenspec(x,y,sText,[]);
   return
end

% Get subplot/report-dependent settings and
% determine the color limits to use
if ndims(b)==2
   numAx=1;
else
   numAx=size(b,3);
end

% Determine the color limits to use
if isempty(clim)
   ind=find(f<=fmax);
   bmin=min(min(b(ind,:)));
   bmax=max(max(b(ind,:)));
   clim=log10([bmin bmax]);
end

[sTextPosition,sFigure]=figtextsettings(numAx,sReport);

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

% Gather settings
tmin=min(t);
tmax=max(t);
fmin=flim(1);
fmax=flim(2);

% Plot lines
h.AxesALL=[];
h.AxesColorbarALL=[];
for r=numAx:-1:1
   
   % RowCol identifier
   strSuffix=sprintf('%d1',r);
   
   % Plot image
   hAxes=subplot(numAx,1,r);
   hImage=imagesc(t,f,log10(b(:,:,r)),clim);axis xy
   
   % Tag image and colorbar
   strImageTag=['Image' strSuffix];
   set(hImage,'tag',strImageTag);
   
   % Add image and colorbar to handle structure
   h=setfield(h,strImageTag,hImage);
   
   % Set some axes props
   strAxesTag=['Axes' strSuffix];
   posAxes=getdefaxpos2d(numAx,r,sReport,strOutType); %axes position [x y w h]
   set(hAxes,...
      'FontName','times',...
      'Position',posAxes,...
      'Tag',strAxesTag,...
      'TickDir','out');
   h=setfield(h,strAxesTag,hAxes);
   h.AxesALL=[h.AxesALL; hAxes];
   
   % Put on the colorbar label
   axes(hAxes)
   hColorbarLabel=text(8.9,3.5,[sText.casYStub{r} ' PSD Magnitude [log_{  10}(g^2/Hz)]'],...
      'fontname','times','fontsize',12,'unit','inch','rotation',...
      90,'horiz','center','verti','mid');
   
   % Tag colorbar label
   strColorbarLabelTag=['TextColorbarLabel' strSuffix];
   set(hColorbarLabel,'tag',strColorbarLabelTag);
   
   % Add colorbar
   hAxesColorbar=colorbarpims;
   strColorbarTag=['AxesColorbar' strSuffix];
   set(hAxesColorbar,'tag',strColorbarTag)
   h=setfield(h,strColorbarTag,hAxesColorbar);
   h.AxesColorbarALL=[h.AxesColorbarALL; hAxesColorbar];
   
   % Insert YLabel
   hy=ylabel('Frequency (Hz)');
   strYLabelTag=['TextYLabel' strSuffix];
   h=setfield(h,strYLabelTag,hy);
   
   % If bottom axes, then add XLabel & Version
   if r==numAx
      h=bottomxlabtext(h,hAxes,sTextPosition.xyzVersion,sText);
   else
      set(hAxes,'XTickLabel',[]);
   end
   
   % If top axes, then add Title & Upper text
   if r==1
      sTextPosition.xUR=1.18; % tweak x position of UR text for colorbar
      h=uppertitletext(h,hAxes,sTextPosition,sFigure,sText);
   end
   
end

% Set axes limits
set(h.AxesALL,'xlim',[tmin tmax]);
set(h.AxesALL,'ylim',[fmin fmax]);

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
sText.casRS={{'RightSide{1}{1}','RightSide{1}{2}'};{'RightSide{2}{1}','RightSide{2}{2}'};{'RightSide{3}{1}','RightSide{3}{2}'}};
sReport.strTitle='This is sReport.strTitle';
sReport.numPage=432;
sReport.numFig=99;
sReport.strCaption='This is sReport.strCaption';
