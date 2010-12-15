function [sHandles]=qth(varargin)


% This function is used to do the 3-Dimensional Color Projection (density)
% plots.
% [sHandles]=qth(data,header,sParameters)

%
% Author: Eric Kelly
% $Id: qth.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Get inputs from syntax 
switch nargin
case 2 % gui call
   [hDisposalFig,sParameters]=deal(varargin{:});
   h=guidata(hDisposalFig);
   data=h.data;
   sHeader=h.sHeader;
   sSearch=h.sSearchCriteria;
   sPlot=sParameters.sPlot;
   sOutput=sParameters.sOutput;
   strComment=sParameters.strComment;
   sCoord=sParameters.sCoord;
   sMap=sParameters.sMap;
case 4 % command line call
   [data,sHeader,sParameters,strComment]=deal(varargin{:});
   sSearch=sParameters.sSearchCriteria;
   sPlot=sParameters.sPlot;
   sOutput=sParameters.sOutput;
   sCoord=sParameters.sCoord;
   sMap=sParameters.sMap;
   
otherwise
   error('wrong nargin')
end

% Adjust for NaNs in plot
numTimeNaN = (sum(isnan(data(:,2))))/sHeader.SampleRate;
sPlot.TSpan = sPlot.TSpan - (numTimeNaN* getsf('seconds',sPlot.TUnits));

% Get upper left text
% NOTE - watch for when mapping takes place!!!!!!!!1
%sText.casUL = top2textul(sHeader);

%   Coordinate System Transformation
% compare the Name and Time, if they are different, do transformation
   if ~(strcmp(sHeader.DataCoordinateSystemName,sParameters.sCoord.Name)...
         & strcmp(sHeader.DataCoordinateSystemTime,sParameters.sCoord.Time))
      [data,sHeader] = transformcoord(data,sHeader,sParameters.sCoord);
   end
   
   %  DO Mapping Routines for quasi-steady data
   if ~isempty(findstr(sHeader.DataType,'tmf'))
      if ~(strcmp(sHeader.SensorCoordinateSystemName, sParameters.sMap.Name) &...
            strcmp(sHeader.SensorCoordinateSystemComment,sParameters.sMap.Comment)); 
         sTempParam.sMap = sMap;sTempParam.sCoord=sCoord;
         [data,sHeader] = qsmapping(data,sHeader,sTempParam,sSearch);
      end
   end
   
   % Get upper left text
% NOTE - watch for when mapping takes place!!!!!!!!1
sText.casUL = top2textul(sHeader);

%Convert acceleration units (if needed)
[data(:,2:end),sHeader,tScaleFactor,strNewTUnits,gScaleFactor]=convertunits(data(:,2:end),sHeader,sPlot);

% Setup the page
%hFig = figure;
%clf
%orient landscape;
%sFigure.PaperPosition = [.25 .125 10.5 7.75];
%set(gcf,'paperposition',sFigure.PaperPosition);

% Get subplot/report-dependent settings
numAx=1;
sReport=[];
[sTextPosition,sFigure]=figtextsettings(numAx,sReport);

% Figure layout
%sFigure.PaperPosition = [.25 .125 10.5 7.75];
sFigure.Position=getdeffigpos('landscape'); %screen position
sFigure.Tag=sprintf('Figure%dx1',numAx);
hFig=figure(...
   'Color',[1 1 1],...
   'PaperOrientation',sFigure.PaperOrientation,...
   'PaperPosition',sFigure.PaperPosition,...
   'Position',sFigure.Position,...
   'Tag',sFigure.Tag);
h=struct(sFigure.Tag,hFig);

% Calculate the bins
low =min(min(data(:,2:4)));
high=max(max(data(:,2:4)));
binres = getsf(sHeader.GUnits,sPlot.GUnits)*sPlot.BinRes;
%binres = double(units([sParameters.plot.GUnits '/' header.GUnits])*sParameters.plot.BinRes);

% ------ THIS LINE IS CHANGED FROM Release 1, to accomodate bin adding --- %
% ------ ADDED indvidual axes bins from sPlot                          --- %
%bins=[low binres ceil((high-low)/binres)];
% ------ THIS LINE IS CHANGED FROM Release 1, to accomodate bin adding --- %

% Count the number of NaNs, NaNs are placed in bin(1,1), this needs to be subtracted off 
% of the first bin in temp
nantotal = length(find(isnan(data(:,2))));
total=length(data(:,2)) - nantotal;

binsX=[sPlot.XLim(1) binres ceil((sPlot.XLim(2)-sPlot.XLim(1))/binres)];
binsY=[sPlot.YLim(1) binres ceil((sPlot.YLim(2)-sPlot.YLim(1))/binres)];
binsZ=[sPlot.ZLim(1) binres ceil((sPlot.ZLim(2)-sPlot.ZLim(1))/binres)];

% In 12.1 the hist2d does not put the NAN in the first spot so make nantotal = 0;
strVersion = version;
if strcmp(strVersion,'6.1.0.450 (R12.1)')
    nantotal = 0;
end

% Make histogram matrices and create sparse matrices to save space
[temp,vx11,vy11]=hist2d(data(:,2),data(:,4),binsX,binsZ);  % the XZ-plane
temp(1,1) = temp(1,1) - nantotal;
hxz = sparse(temp);

[temp,vx12,vy12]=hist2d(data(:,3),data(:,4),binsY,binsZ);  % the YZ-plane
temp(1,1) = temp(1,1) - nantotal;
hyz = sparse(temp);

[temp,vx21,vy21]=hist2d(data(:,2),data(:,3),binsX,binsY);  % the XY-plane
temp(1,1) = temp(1,1) - nantotal;
hxy = sparse(temp);

clear temp;

% Save into temp file 
sInfo = get(0,'UserData');
tempSavePath = sInfo.sUser.ResultsPath;
if ~exist(tempSavePath)
    strOldDir = pwd;
    [statusVal,strMsg]=pimsmkdir(tempSavePath);
end
tempFileName = popdatestr(sHeader.sdnDataStart,-3.1);
tempFileName = fullfile(tempSavePath, [tempFileName(1:19) '_qthfile']);
TSpan = sPlot.TSpan;
save(tempFileName,'hxz','hyz','hxy','vx11','vy11','vx12','vy12','vx21','vy21','total','TSpan');

% Convert "hits" to percentage of time, disregarding NaN
hxz=(hxz./total)*100;
hyz=(hyz./total)*100;
hxy=(hxy./total)*100;

% Calculate the colorlimits
if strcmp(sPlot.CLimMode,'min/max')
   Cmin=min([min(hxz) min(hyz) min(hxy)]);
   Cmax=max([max(hxz) max(hyz) max(hxy)]);
   CLim=[Cmin Cmax];
else 
   CLim = sParameters.plot.CLim;
end

% Initialize the handle matrices
hAxes=zeros(3,2);
hImages = zeros(3,2);
hLines = zeros(3,3);
hText = zeros(10,1);

% Plot the XY Plane
%hAxes(2,1)=subplot(2,2,3);
hAxes(2,1)=subplot('position',[.11 .11 .3270 .3720]);
hImages(2,1) = imagesc(vx21,vy21,hxy,CLim); axis xy, axis('square');
colormap(sPlot.Colormap);
set(hAxes(2,1),'Tag','AxesXYPlane');
set(hImages(2,1),'Tag','ImageXYPlane');
h=xlabel(sprintf('X-Axis Accel. (%s)',sPlot.GUnits),'fontname','Helvetica');
set(h,'Tag','TextXlabelXYPlane');
h=ylabel(sprintf('Y-Axis Accel. (%s)',sPlot.GUnits),'fontname','Helvetica');
set(h,'Tag','TextYlabelXYPlane');
set(gca,'fontname','Helvetica');
set(gca,'tickdir','out');

% Plot the YZ Plane
%hAxes(1,2) = subplot(2,2,2);
hAxes(1,2)=subplot('position',[.5780 .5530 .3270 .3720]);
hImages(1,2)=imagesc(vx12,vy12,hyz,CLim); axis xy, axis('square');
colormap(sPlot.Colormap);
set(hAxes(1,2),'Tag','AxesYZPlane');
set(hImages(1,2),'Tag','ImageYZPlane');
h=xlabel(sprintf('Y-Axis Accel. (%s)',sPlot.GUnits),'fontname','Helvetica');
set(h,'Tag','TextXlabelYZPlane');
h=ylabel(sprintf('Z-Axis Accel. (%s)',sPlot.GUnits),'fontname','Helvetica');
set(h,'Tag','TextYlabelYZPlane');
set(gca,'fontname','Helvetica');
set(gca,'tickdir','out');

% Plot the XZ Plane
%hAxes(1,1)=subplot(2,2,1);
hAxes(1,1)=subplot('position',[.11 .5530 .3270 .3720]);
hImages(1,1)=imagesc(vx11,vy11,hxz,CLim); axis xy, axis('square');
set(hAxes(1,1),'Tag','AxesXZPlane');
set(hImages(1,1),'Tag','ImageXZPlane');
h=xlabel(sprintf('X-Axis Accel. (%s)',sPlot.GUnits),'fontname','Helvetica');
set(h,'Tag','TextXlabelXZPlane');
h=ylabel(sprintf('Z-Axis Accel. (%s)',sPlot.GUnits),'fontname','Helvetica');
set(h,'Tag','TextYlabelXZPlane');
set(gca,'fontname','Helvetica');
set(gca,'tickdir','out');

% Set the axes limits
axes(hAxes(1,1))
axis([sPlot.XLim sPlot.ZLim]);
axes(hAxes(1,2))
axis([sPlot.YLim sPlot.ZLim]);
axes(hAxes(2,1))
axis([sPlot.XLim sPlot.YLim]);

% Calculate the centroid, cb is the distance from bin edge to center of bin
cb = binres/2;
cxz=nancentroi2(vx11+cb,vy11+cb,hxz);
cxy=nancentroi2(vx21+cb,vy21+cb,hxy);
cxyz = [cxy(1) cxy(2) cxz(2)];

%%%%%%% Make the Grid Lines %%%%%%%%%

% The center of the gridlines
if strcmp(sPlot.GridCenter,'centroid')  
   Oxyz = cxyz;  % The centroid
else
   Oxyz = [0 0 0];  % The origin
end

% calculate percentile circles
vecmag = pimsrss(data(:,2)-Oxyz(1),data(:,3)-Oxyz(2),data(:,4)-Oxyz(3)); 
upbound = nanmedian(vecmag);
[Radius] = fminbnd('calcpercentincircle',0,upbound,optimset('Display','off'),vecmag,total,sPlot.GridPercent);


% Plot the circle for the XZ Plane
axes(hAxes(1,1))
hold on;
[x_circ,y_circ] = circle(Radius,Oxyz([1 3]),60);
hLines(1,1)=plot(x_circ,y_circ,'color',convertcolor(sPlot.GridColor),...
   'linewidth',0.8,'linestyle',convertstyle(sPlot.GridLineStyle));
set(hLines(1,1),'Tag','LineCircleXZ');
hold off
% Plot the circle for the YZ Plane
axes(hAxes(1,2))
hold on;
[x_circ,y_circ] = circle(Radius,Oxyz([2 3]),60);
hLines(2,1)=plot(x_circ,y_circ,'color',convertcolor(sPlot.GridColor),...
   'linewidth',0.8);
set(hLines(2,1),'Tag','LineCircleYZ','linestyle',convertstyle(sPlot.GridLineStyle));
hold off
% Plot the circle for the XY Plane
axes(hAxes(2,1))
hold on;
[x_circ,y_circ] = circle(Radius,Oxyz([1 2]),60);
hLines(3,1)=plot(x_circ,y_circ,'color',convertcolor(sPlot.GridColor),...
   'linewidth',0.8);
set(hLines(3,1),'Tag','LineCircleXY','linestyle',convertstyle(sPlot.GridLineStyle));
hold off


% Add the crosshairs for XZ Plane
axes(hAxes(1,1))
hold on
lims=axis;
hLines(1,2)=line([lims(1) lims(2)],[Oxyz(3) Oxyz(3)],'color',convertcolor(sPlot.GridColor),'linewidth',0.8);
set(hLines(1,2),'Tag','LineCrosshairXZHoriz','linestyle',convertstyle(sPlot.GridLineStyle));
hLines(1,3)=line([Oxyz(1) Oxyz(1)],[lims(3) lims(4)],'color',convertcolor(sPlot.GridColor),...
   'linewidth',0.8);
set(hLines(1,3),'Tag','LineCrosshairXZVert','linestyle',convertstyle(sPlot.GridLineStyle));
hold off;

% Add the crosshairs for YZ Plane
axes(hAxes(1,2))
hold on
lims=axis;
hLines(2,2)=line([lims(1) lims(2)],[Oxyz(3) Oxyz(3)],'color',convertcolor(sPlot.GridColor),...
   'linewidth',0.8);
set(hLines(2,2),'Tag','LineCrosshairYZHoriz','linestyle',convertstyle(sPlot.GridLineStyle));
hLines(2,3)=line([Oxyz(2) Oxyz(2)],[lims(3) lims(4)],'color',convertcolor(sPlot.GridColor),...
   'linewidth',0.8);
set(hLines(2,3),'Tag','LineCrosshairYZVert','linestyle',convertstyle(sPlot.GridLineStyle));
hold off;

% Add the crosshairs for XY Plane
axes(hAxes(2,1))
hold on;
lims=axis;
hLines(3,2)=line([lims(1) lims(2)],[Oxyz(2) Oxyz(2)],'color',convertcolor(sPlot.GridColor),...
   'linewidth',0.8,'linestyle',convertstyle(sPlot.GridLineStyle));
set(hLines(3,2),'Tag','LineCrosshairXYHoriz');
hLines(3,3)=line([Oxyz(1) Oxyz(1)],[lims(3) lims(4)],'color',convertcolor(sPlot.GridColor),...
   'linewidth',0.8,'linestyle',convertstyle(sPlot.GridLineStyle));
set(hLines(3,3),'Tag','LineCrosshairXYVert');
hold off

% Turn off the crosshairs and/or percentile circle
if strcmp(sPlot.GridMode,'crosshair')
   set(hLines(:,1),'Visible','off');
elseif strcmp(sPlot.GridMode,'percentile')
   set(hLines(:,2:3),'Visible','off');
else
   set(hLines,'Visible','off');
end

% Determine T
%T=num2str(max(data(:,1))-min(data(:,1)));

% Colorbar and extra data info axes
%hAxes(2,2) = subplot(2,2,4);
hAxes(2,2) = subplot('position',[.5780 .11 .3270 .3720]);

% Create dummy image in invisible axes to store CLim in UserData, Colorbarpims1 gets CLim from here.
mDummy = [CLim;0 0];
hImages(3,2)=imagesc(mDummy,CLim);
colormap(sPlot.Colormap);
set(hImages(3,2),'Visible','off','Tag','ImageDummy');

% Create the colorbar
axes(hAxes(2,2)); axis off;
hImages(2,2) = colorbarpims;
set(hImages(2,2),'position',[.8580 .11 .0245 .3720]);
set(hImages(2,2),'Tag','ImageColorBar','yAxisLocation','right');
colormap(sPlot.Colormap);
axes(hImages(2,2));
h=ylabel('Percentage of Time','fontname','Helvetica');
set(h,'Tag','TextYlabelColorbar');
set(hAxes(2,2),'Tag','AxesDataInfo');

% Create the Ancillary Data Axis 
hAxes(3,1) = axes;
posAxes=getdefaxpos2d(1,1,sReport,sOutput.Type); %axes position [x y w h]
set(hAxes(3,1),'Tag','AxesAncillaryData','pos',posAxes);
axis off;
send2back(hAxes(3,1));

% moved this line to before transformation
%sText.casUL = top2textul(sHeader);


sText.casUR = top2textur(sHeader);
sText.casUR{3} = sprintf('Resolution = %s %s',num2str(binres),sPlot.GUnits);

sText.casUL{3} = sprintf('Time Span = %s %s',num2str(sPlot.TSpan),sPlot.TUnits);

sText.strComment=strrep(strComment,'_','\_');
sText.strTitle=starttimetitle(sHeader.sdnDataStart,sSearch.PathQualifiers.strTimeBase,sSearch.PathQualifiers.strTimeFormat);
strDataSource=sSearch.PathQualifiers.strBasePath;
sText.strVersion=bottomdateline(strDataSource);

h=uppertitletext(h,hAxes(3,1),sTextPosition,sFigure,sText);

% Set new Title Position
TitlePos = get(h.TextTitle,'pos');
TitlePos(2) = 1.05;
set(h.TextTitle,'pos',TitlePos);

% Set new Comment Position
CommentPos = get(h.TextTitle,'pos');
CommentPos(2) = 1.0825;
set(h.TextTitle,'pos',CommentPos);


if ( isfield(sText,'strVersion') & ~isempty(sText.strVersion) )
   h.TextVersion = text(...
      'Parent',hAxes(3,1), ...
      'Units','normalized', ...
      'Color',[0 0 0], ...
      'FontName','Helvetica', ...
      'FontSize',4, ...
      'HorizontalAlignment','right', ...
      'Position',sTextPosition.xyzVersion,...
      'Interpreter','none',...
      'String',sText.strVersion, ...
      'Tag','TextVersion');
end

% The centroid information
crss = pimsrss(cxyz(1),cxyz(2),cxyz(3));
strtemp = sprintf('Centroid:\n   Xct = %+7.3f (%s)\n   Yct = %+7.3f (%s)\n   Zct = %+7.3f (%s)\n   Magnitude = %+7.3f (%s)',...
   cxyz(1),sPlot.GUnits,cxyz(2),sPlot.GUnits,cxyz(3),sPlot.GUnits,crss,sPlot.GUnits);
%hText(11) = text(1,1,strtemp,'fontname','Helvetica','position',[.5780 .3840 0]);
hText(11) = text(1,1,strtemp,'fontname','Helvetica','position',[.5780 .4440 0]);
set(hText(11),'Tag','TextCentroid');


% The percent visible data
[visperc,vismess]=calcqthvisible(data,sPlot);
strtemp = sprintf('Percentage of Data Visible:\n   %s\n   %s\n   %s',vismess{1},vismess{2},vismess{3});
%hText(12) = text(1,1,strtemp,'fontname','Helvetica','position',[.5780 .2640 0]);
hText(12) = text(1,1,strtemp,'fontname','Helvetica','position',[.5780 .3040 0]);
set(hText(12),'Tag','TextPercent','Visible',sPlot.DispPercent);

%The spherical radius
[visperc,vismess]=calcqthvisible(data,sParameters.sPlot);
strtemp = sprintf('Minimum Spherical Radius:\n   Center = %s\n   Percentile = %6.2f\n   Radius = %7.3f (%s)',...
   sPlot.GridCenter,sPlot.GridPercent,Radius,sPlot.GUnits);
hText(13) = text(1,1,strtemp,'fontname','Helvetica','position',[.5780 .1840 0]);
set(hText(13),'Tag','TextRadius','Visible',sPlot.DispMinRad);

% Gte the sHandles structure and remove conflicting Figure name
sHandles = guihandles(hFig);
if isfield(sHandles,'FigureToolBar')
    sHandles = rmfield(sHandles,'FigureToolBar');
end
