function sHandles=qscomp(varargin);

%qscomp - quasi-steady compliance check
%
%sHandles=gvt(hDisposalFig,sDisposition); % gui syntax
%or
%sHandles=gvt(data,sHeader,sParameters,strComment); % command line
%
%Inputs: hFigDisposal - scalar handle of disposal figure
%        sDisposition - structure for dispositon (from disposal gui)
%or
%        data - matrix of [t x y z] columns
%        sHeader - structure of header info
%        sParameters - nested structure of .sPlot, .sOutput parameters
%        strComment - string for comment
%
%Outputs: sHandles - structure of handles

%Author: Eric Kelly 
% $Id: qscomp.m 4160 2009-12-11 19:10:14Z khrovat $

% Get inputs from syntax 
switch nargin
case 2 % gui call
   [hDisposalFig,sDisposition]=deal(varargin{:});
   h=guidata(hDisposalFig);
   data=h.data;
   sHeader=h.sHeader;
   sSearch=h.sSearchCriteria;
   sPlot=sDisposition.sPlot;
   sOutput=sDisposition.sOutput;
   strComment=sDisposition.strComment;
   sCoord = sDisposition.sCoord;
   if isfield(sDisposition,'sMap')
      sMap = sDisposition.sMap;
   end
   if isfield(sDisposition,'sBias')
      sBias = sDisposition.sBias;
   end
case 4 % command line call
   [data,sHeader,sParameters,strComment]=deal(varargin{:});
   sSearch=sParameters.sSearchCriteria;
   sPlot=sParameters.sPlot;
   sOutput=sParameters.sOutput;
   sCoord = sParameters.sCoord;
   if isfield(sParameters,'sMap')
      sMap = sParameters.sMap;
   end
   if isfield(sParameters,'sBias')
      sBias = sParameters.sBias;
   end
otherwise
   error('wrong nargin')
end % switch nargin

% Get top left standard lines of ancillary text
%sText.casUL=top2textul(sHeader);

% Remove bias intervals from ossraw and apply bias compensation, if necessary
if strcmp(sHeader.DataType,'mams_accel_ossraw');
   if (sDisposition.sBias.RemoveBiasPeriods==1)
      indBias = ismamsbias(data(:,6));
      data(indBias,2:5) = nan;
   end
   
   if strcmp(sDisposition.sBias.Action,'apply')
      [data,sHeader] = applymamsbias(data,sHeader,sDisposition.sBias);
   end  
end

% Coordinate System Transformation
if ~strcmp(sPlot.WhichAx,'vecmag')
   % compare the Name and Time, if they are different, do transformation
   if ~(strcmp(sHeader.DataCoordinateSystemName,sCoord.Name)...
         & strcmp(sHeader.DataCoordinateSystemTime,sCoord.Time))
      [data,sHeader] = transformcoord(data,sHeader,sCoord);
   end
else
   sText.casUR{2} = 'Vector Maginitude'; 
end

% Get top Right standard lines of ancillary text
sText.casUR=top2textur(sHeader);

% DO Mapping Routines for quasi-steady data
if ~isempty(findstr(sHeader.DataType,'tmf'))
   if ~(strcmp(sHeader.SensorCoordinateSystemName, sMap.Name) &...
         strcmp(sHeader.SensorCoordinateSystemComment,sMap.Comment)); 
      sTempParam.sMap = sMap;sTempParam.sCoord=sCoord;
      [data,sHeader] = qsmapping(data,sHeader,sTempParam,sSearch);
   end
end

% Get top left standard lines of ancillary text
sText.casUL=top2textul(sHeader);

% Convert acceleration units (if needed)
[data(:,2:end),sHeader,tScaleFactor,strNewTUnits,gScaleFactor]=convertunits(data(:,2:end),sHeader,sPlot);

% The duration of one orbit in seconds
orbitlength =  5400;

% Determine appropriate sampling interval in number of points
interval = round(orbitlength * sHeader.SampleRate);

% Calculate orbital average,maximum and component vectors 
[qscdata] = calcqsvector(data,interval);

% Partition data & gather some text for generic call to plotgen2d
secSpan=qscdata(end,1)-qscdata(1,1); 
t=qscdata(:,1)*tScaleFactor;  % [converted units] time relative to sHeader.sdnDataStart
qscdata(:,1)=[]; % get rid of time column
[c1,c2,c3,sText.strXType,strYType]=popdatatypes(sHeader.DataType);
clear c1 c2 c3 % just need the XType, YType, & YUnits text
strWhichAx=sPlot.WhichAx;

sText.casYStub={'Orbital Average';'Vector Magnitude';'Perpendicular Magnitude'}; % YLabel stubs

% Gather rest of text for generic call to plotgen2d
numAx=nCols(data);
sText.casYTypes=repmat({strYType},numAx,1);
sText.strXUnits=sPlot.TUnits;
strYUnits=texunits(sHeader.GUnits);
sText.casYUnits=repmat({strYUnits},nCols(data),1);
sText.casRS=locGetRightSideText(strWhichAx,sHeader.GUnits,sHeader.DataType);
sText.strComment=strrep(strComment,'_','\_');
sText.strTitle=starttimetitle(sHeader.sdnDataStart,sSearch.PathQualifiers.strTimeBase,sSearch.PathQualifiers.strTimeFormat);
sText.strVersion=bottomdateline(sSearch.PathQualifiers.strBasePath);

% Branch on output type
strOutputType=lower(sOutput.Type);

% Take advantage of plotgen2d to plot orbavg x-accleration, instantaneous magnitude and perpendicular maginitude
sHandles = locGenFig(t,qscdata(:,[1 5 6]),sHeader,sText,sSearch,sPlot,...
   sOutput,gScaleFactor,strWhichAx,strYType,numAx);

% create vectors for limit plots
maglimit = ones(size(t));
perplimit = .2*ones(size(t));

% Add Y and Z lines to orbavg
axes(sHandles.Axes11);
hold on;
set(sHandles.Line11,'color','r');
hTemp = plot(t,qscdata(:,2),'g');set(hTemp,'Tag','Line12');
hTemp = plot(t,qscdata(:,3),'b');set(hTemp,'Tag','Line13');
set(sHandles.Axes11,'YLim',[-2 2]*1e6/gScaleFactor,'YTick',[-2 -1.5 -1 -.5 0 .5 1 1.5 2]*1e6/gScaleFactor);
hTemp = legend('X','Y','Z',2);
set(hTemp,'FontName','Helvitica','FontSize',8);

% Add accleration magnitude and limit line
axes(sHandles.Axes21);
hold on;
hTemp = plot(t,qscdata(:,4),'k');set(hTemp,'Tag','Line22');
set(sHandles.Line21,'color',[.6 .6 .6]);
hTemp = plot(t,maglimit,'m');set(hTemp,'Tag','Line23');
set(hTemp,'LineStyle','--');
set(sHandles.Axes21,'YLim',[0 2.5]*1e6/gScaleFactor);
hTemp = legend('OSS','Orbital Avg.','Mag. Limit',2);
set(hTemp,'FontName','Helvitica','FontSize',8);

% Add limit line to perpendicular magnitude
axes(sHandles.Axes31);
hold on;
hTemp = plot(t,perplimit,'m');set(hTemp,'Tag','Line32');
set(hTemp,'LineStyle','--');
set(sHandles.Axes31,'YLim',[0 1]*1e6/gScaleFactor);
hTemp = legend('Perpendicular','Perp. Limit',2);
%set(hTemp,'FontName','Helvitica','FontSize',8);

% Add print menu to figure
[hMenu,strFilename]=addprintmenu(gcf,secSpan);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casRS=locGetRightSideText(strWhichAx,strGUnits,strDataType);

%casRS{1}{1}=sprintf('Mean = %.4f %s',dataMean,strGUnits);
%casRS{1}{2}=sprintf('RMS = %.4f %s',dataRMS,strGUnits);

casRS{1}{1}='';
casRS{1}{2}='';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sHandles] = locGenFig(t,qscdata,sHeader,sText,...
   sSearch,sPlot,sOutput,gScaleFactor,strWhichAx,strYType,numAx)
% Plot data with generic 2D plot routine

sHandles=plotgen2d(t,qscdata,sText,sOutput.Type,[]);

% Get Time Axes Limit - this is part of a work around for a 
% bug that changes the Center plots XLIM values when the 
% YLimMode is set
TAxesLimits = get(sHandles.AxesALL,'xlim');

% Incorporate plot parameter settings
if strcmp(sPlot.TLimMode,'auto')
   set(sHandles.AxesALL,'xlimmode','auto');
else
   set(sHandles.AxesALL,'xlimmode','manual','xlim',sPlot.TLim);
end
if strcmp(sPlot.GLimMode,'auto')
   set(sHandles.AxesALL,'ylimmode','auto');
   if numAx>1
      setscalenote(sHandles.AxesALL,1);
   end
else
   set(sHandles.AxesALL,'ylimmode','manual','ylim',sPlot.GLim);
   
   %  Second part of work around, reset to previous value if
   % TLimmode set to auto and GLimMode set to manual
   if strcmp(sPlot.TLimMode,'auto') & strcmp(strWhichAx,'xyz')
      set(sHandles.AxesALL,'xlimmode','auto');
      set(sHandles.AxesALL,'xlim',TAxesLimits{1});
   end
end

% Put name on figure
set(gcf,'Name',figname(mfilename,strWhichAx));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% revise to something like: sHandles=locMenus4gvt(?); %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Need to modularize these specialized menus where possible
casBrowseLabels=strcat(strrep(sText.casYStub,'-','_'),['_' sHeader.GUnits]);
casBrowseLabels=strrep(casBrowseLabels,' ','');
%loadsptool(data,sHeader.SampleRate,casBrowseLabels)
switch strWhichAx
case 'xyz'
   strGetData=[      'data=get(' num2str(sHandles.Line11,22)...
         ',''ydata'')'';data=[data get(' num2str(sHandles.Line21,22)...
         ',''ydata'')''];data=[data get(' num2str(sHandles.Line31,22) ',''ydata'')''];'];
   strRest=[num2str(sHeader.SampleRate,22) ',{''' casBrowseLabels{1} ''',''' casBrowseLabels{2} ''',''' casBrowseLabels{3} '''});'];
   strBrowseLabels='>XYZ';
   strBrowseCalls=[strGetData 'loadsptool(data,' strRest];
case 'vecmag'
   strGetData=[      'data=get(' num2str(sHandles.Line11,22) ',''ydata'')'';'];
   strRest=[num2str(sHeader.SampleRate,22) ',{''' casBrowseLabels{1} '''});'];
   strBrowseLabels='>VecMag';
   strBrowseCalls=[strGetData 'loadsptool(data,' strRest];
case 'x'
   strGetData=[      'data=get(' num2str(sHandles.Line11,22) ',''ydata'')'';'];
   strRest=[num2str(sHeader.SampleRate,22) ',{''' casBrowseLabels{1} '''});'];
   strBrowseLabels='>X';
   strBrowseCalls=[strGetData 'loadsptool(data,' strRest];
case 'y'
   strGetData=[      'data=get(' num2str(sHandles.Line11,22) ',''ydata'')'';'];
   strRest=[num2str(sHeader.SampleRate,22) ',{''' casBrowseLabels{1} '''});'];
   strBrowseLabels='>Y';
   strBrowseCalls=[strGetData 'loadsptool(data,' strRest];
case 'z'
   strGetData=[      'data=get(' num2str(sHandles.Line11,22) ',''ydata'')'';'];
   strRest=[num2str(sHeader.SampleRate,22) ',{''' casBrowseLabels{1} '''});'];
   strBrowseLabels='>Z';
   strBrowseCalls=[strGetData 'loadsptool(data,' strRest];
otherwise
   error(sprintf('unknown axis %s',strWhichAx));
end
strAllAxLim=allaxlimdlg(sHandles.AxesALL,sText.strXType,strYType);
strTest=sprintf('''sdnStart: %s, xlim=[%g %g] which units?''',popdatestr(sHeader.sdnDataStart,0),get(sHandles.Axes11,'xlim'));
mnuLabels=str2mat( ...
   '&View', ...
   '&Browse', ...
   strBrowseLabels, ...
   '&Options', ...
   '>&Axis', ...
   '>&NewStart', ...
   '>&DateTick'...
   );
mnuCalls=str2mat( ...
   'disp(''View'')', ...
   '', ...
   strBrowseCalls, ...
   '', ...
   strAllAxLim, ...
   'disp(''Replot with tmin as tzero for synched currently viewed region (toss unused data, adjust header and time).'')',...
   strTest...
   );
sHandles.Menu=makemenu(gcf,mnuLabels,mnuCalls);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   end of something like: sHandles=locMenus4gvt(?);  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
