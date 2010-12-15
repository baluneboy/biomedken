function h=plotpcsa(fBins,pBins,H,numPSDs,sText,strOutType,CLim);

%plotpcsa
%
%h=plotpcsa(fBins,pBins,H,sText,strOutType,sReport,FLim,CLim);
%
%Inputs: fBins - vector of frequency bins
%        pBins - vector of PSD bins
%        H - histogram matrix of PSD values
%        numPSDs - scalar count of PSDs
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
%        CLim - colorbar limits (like [-14 -3])
%
%Outputs: h - structure of handles

%Author: Ken Hrovat, 1/20/2001
% $Id: plotpcsa.m 4160 2009-12-11 19:10:14Z khrovat $

sReport=[];% forever?

% Get dummy inputs for template show and tell
if nargin==0
   %[x,y,sText,sReport]=locDummyInputs;
   %h.p1x1=plotpcsa(x,y(:,1),sText,[]);
   [x,y,z,numPSDs,sText,CLim]=locDummyInputs;
   h.p3x1=plotpcsa(x,y,z,numPSDs,sText,'screen',CLim);
   return
end

% Get subplot/report-dependent settings and
% determine the color limits to use
if ndims(H)==2
   numAx=1;
else
   numAx=size(H,3);
end

[sTextPosition,sFigure]=figtextsettings(numAx,sReport);
sTextPosition.xUR=1.18; % tweak x position of UR text for colorbar

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

% Plot image(s)
h.AxesALL=[];
h.ImageALL=[];
h.AxesColorbarALL=[];
for r=numAx:-1:1
   
   % RowCol identifier
   strSuffix=sprintf('%d1',r);
   
   % Plot image
   hAxes=subplot(numAx,1,r);
   hImage=imagesc(fBins,pBins,100*(H/numPSDs),CLim);axis xy
   %hImage=imagesc(fBins,pBins,100*(H/numPSDs));axis xy
   colormap(pimsmap2)
   h.ImageALL=[h.ImageALL hImage];
   
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
   set(h.AxesALL,'ylim',[pBins(1) pBins(end)+(pBins(2)-pBins(1))]);
   
   % Put on the colorbar label
   axes(hAxes)
   hColorbarLabel=text(1.04,0.5,[sText.casYStub{r} ' Percentage of Time'],...
      'units','normalized','fontname','times','fontsize',10,'rotation',90,'horiz','center','verti','mid');
   
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
   hy=ylabel('PSD Magnitude [log_{ 10}(g^2/Hz)]');
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
      h=uppertitletext(h,hAxes,sTextPosition,sFigure,sText);
   end
   
end

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [freqBins,PSDBins,H,numPSDs,sText,CLim]=locDummyInputs;
%load clown
%x=1:nRows(X);
%y=1:nCols(X);
%CLim=[0 80];
%numPSDS=sum(X(:,1));
CLim=[0 2];
load T:\offline\batch\results\inc02\121f06\spectrogram\SAMSf_tp023296\pcsa\SAMSf_tp023296_hist2d
load T:\offline\batch\results\inc02\121f06\spectrogram\SAMSf_tp023296\pcsa\2001_07_15_08_00_00_121f06_pcsas_SAMS121f06_001
sText.strXType='Frequency';
sText.strXUnits='Hz';
sText.casYStub={'ystub1','ystub2','ystub3'};
sText.casYTypes='YType';
sText.casYUnits='YUnits';
sText.casUL={'UpLeft{1}','UpLeft{2}','12345678901234567890','UpLeft{4}'};
sText.casUR={'UpRight{1}','UpRight{2}','09876543210987654321','UpRight{4}'};
sText.strComment='This is sText.strComment';
sText.strTitle='sText.strTitle';
sText.casRS={{'RightSide{1}{1}','RightSide{1}{2}'};{'RightSide{2}{1}','RightSide{2}{2}'};{'RightSide{3}{1}','RightSide{3}{2}'}};
sText.strVersion='version control string';