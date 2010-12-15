function sHandles=leakyint(varargin);

%leakyint - velocity versus time
%
%sHandles=leakyint(hDisposalFig,sDisposition); % gui syntax
%or
%sHandles=leakyint(data,sHeader,sParameters,strComment); % command line
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

%Author: Ken Hrovat, 9/24/2002
%$Id: leakyint.m 4160 2009-12-11 19:10:14Z khrovat $

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

% Partition data & gather some text for generic call to plotgen2d
secSpan=data(end,1)-data(1,1); 
t=data(:,1)*tScaleFactor;  % [converted units] time relative to sHeader.sdnDataStart
%data=padinterpolate(data); % interpolate NaN gaps
data(:,1)=[]; % get rid of time column
[c1,c2,c3,sText.strXType,strYType]=popdatatypes(sHeader.DataType);
clear c1 c2 c3 % just need the XType, YType, & YUnits text
strWhichAx=sPlot.WhichAx;
switch strWhichAx
case 'xyz'
   sText.casYStub={'X-Axis';'Y-Axis';'Z-Axis'}; % YLabel stubs
   data=data(:,1:3);
case 'vecmag'
   sText.casYStub={'Velocity Magnitude'};
   strYType=''; % for this case, prefix with YType
   sText.casUR{2} = 'Vector Magnitude';
case 'x'
   sText.casYStub={'X-Axis'};
   data=data(:,1);
case 'y'
   sText.casYStub={'Y-Axis'};
   data=data(:,2);
case 'z'
   sText.casYStub={'Z-Axis'};
   data=data(:,3);
otherwise
   error(sprintf('unknown axis %s',strWhichAx));
end

% Compute mean of data
dataMean=nanmean(data);

% Demean data (if needed)
if strcmp(lower(sPlot.Demean),'yes')
   data=data-ones(nRows(data),1)*dataMean;
end

% Calculate filter coefficients that implement leaky integrator
[b_num,a_den]=sofballfiltcoeffs(sPlot.Discharge,sHeader.SampleRate);

% Compute velocity as leaky integrated acceleration
%data(:,1)=filter(b_num,a_den,data(:,1));
%data(:,2)=filter(b_num,a_den,data(:,2));
%data(:,3)=filter(b_num,a_den,data(:,3));
iNum=find(~isnan(data(:,1)));
[iStarts,durations]=contig(data(:,1),iNum);
for i=1:length(iStarts)
   ind=iStarts(i):iStarts(i)+durations(i)-1;
   data(ind,1)=filter(b_num,a_den,data(ind,1));
   data(ind,2)=filter(b_num,a_den,data(ind,2));
   data(ind,3)=filter(b_num,a_den,data(ind,3));
end

% Compute vector magnitude (if needed)
if strcmp('vecmag',strWhichAx)
   data=pimsrss(data(:,1:3));
   dataMean=nanmean(data); % not original mean
end

% Compute RMS
dataMax=nanmax(data);

% Gather rest of text for generic call to plotgen2d
numAx=nCols(data);
sText.casYTypes=repmat({strYType},numAx,1);
sText.strXUnits=sPlot.TUnits;
strYUnits=texunits(sPlot.VUnits);
sText.casYUnits=repmat({strYUnits},nCols(data),1);
sText.casRS=locGetRightSideText(strWhichAx,dataMean,dataMax,sPlot.VUnits,sHeader.DataType);
sText.strComment=strrep(strComment,'_','\_');
sText.strTitle=starttimetitle(sHeader.sdnDataStart,sSearch.PathQualifiers.strTimeBase,sSearch.PathQualifiers.strTimeFormat);
sText.strVersion=bottomdateline(sSearch.PathQualifiers.strBasePath);

% Branch on output type
strOutputType=lower(sOutput.Type);
switch strOutputType
case 'datafilebat'
   
   sHandles=[]; % no handles to return
   strTrunk=locDoFileBatch(data,sHeader,sDisposition,sText,...
      sSearch,sPlot,sOutput,gScaleFactor,strWhichAx,dataMean,dataMax);
   
   % Add print menu to figure
   [hMenu,strFilename]=addprintmenu(gcf,secSpan);
   
case 'imagefilebat'
   sHandles =[];% no handles to return  
   strTrunk = locDoFileBatch(data,sHeader,sDisposition,sText,...
      sSearch,sPlot,sOutput,gScaleFactor,strWhichAx,dataMean,dataMax);       
   
   sHandles = locGenFig(t,data,sHeader,sText,sSearch,sPlot,...
      sOutput,gScaleFactor,strWhichAx,dataMean,dataMax,strYType,numAx);
   
   % make a directory to store the figures
   strFigPath = [sDisposition.ResultsPath 'figures' filesep];
   if ~exist(strFigPath)
      strOldDir = pwd;
      [statusVal,strMsg]=pimsmkdir(strFigPath);
      if ~isempty(strMsg)
         fprintf('\npimsmkdir message for %s: %s\n',strFigPath,strMsg)
      end
   end
   
   % Add print menu to figure
   [hMenu,strFilename]=addprintmenu(gcf,secSpan);
   
   % save the figure
   strFigName = [strFigPath popdatestr(sHeader.sdnDataStart,-3.1) '_leakyint.fig'];
   hgsave(sHandles.Figure3x1,strFigName);
   close(sHandles.Figure3x1);
   
otherwise
   
   sHandles = locGenFig(t,data,sHeader,sText,sSearch,sPlot,...
      sOutput,gScaleFactor,strWhichAx,dataMean,dataMax,strYType,numAx);
   
   % Add print menu to figure
   [hMenu,strFilename]=addprintmenu(gcf,secSpan);
   
   %%%%%%%%%%% FOR STS-107 %%%%%%%%%%%
   set(sHandles.TextUpperRight1,'str','STS-107');
   iColon=findstr(sText.casUL{1},':');
   str=sText.casUL{1};
   if ~isempty(iColon)
      set(sHandles.TextUpperLeft1,'str',str(1:iColon-1));
   end
   str=sText.casUL{2};
   set(sHandles.TextUpperLeft2,'str',strrep(str,'26.32','26.3'));
   %%%%%%%%%%% FOR STS-107 %%%%%%%%%%%
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casRS=locGetRightSideText(strWhichAx,dataMean,dataMax,strGUnits,strDataType);

if strcmp(strDataType,'mams_accel_ossraw')|strcmp(strDataType,'mams_accel_ossbtmf')
   strMean = 'Mean';
else
   strMean = 'Original Mean';
end

switch strWhichAx
case 'xyz'
   for iCol=1:3
      %casRS{iCol}{1}=sprintf('Original Mean = %.4f %s',dataMean(iCol),strGUnits);
      casRS{iCol}{1}=sprintf([strMean ' = %.4f %s'],dataMean(iCol),strGUnits);
      casRS{iCol}{2}=sprintf('Max = %.4f %s',dataMax(iCol),strGUnits);
   end
case 'vecmag'
   casRS{1}{1}=sprintf('Mean = %.4f %s',dataMean,strGUnits);
   casRS{1}{2}=sprintf('Max = %.4f %s',dataMax,strGUnits);
case {'x','y','z'}
   casRS{1}{1}=sprintf([strMean ' = %.4f %s'],dataMean,strGUnits);
   casRS{1}{2}=sprintf('Max = %.4f %s',dataMax,strGUnits);
otherwise
   strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
   error(strErr)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [strTrunk] = locDoFileBatch(data,sHeader,sDisposition,sText,sSearch,sPlot,sOutput,gScaleFactor,strWhichAx,dataMean,dataMax);

% Path for results
strResultsPath=sDisposition.ResultsPath;
strUnique=sDisposition.UniqueString;
strTrunk=[strResultsPath strUnique '_'];

% Save info file (if first in batch)
strInfoFilename=[strTrunk 'info.mat'];
strHistname=[strTrunk 'hist.mat'];
strStatname=[strTrunk 'stat.mat'];
if ~exist(strInfoFilename)
   if ~exist(strResultsPath)
      [statusVal,strMsg]=pimsmkdir(strResultsPath);
      if ~isempty(strMsg)
         fprintf('\npimsmkdir message for %s: %s\n',strResultsPath,strMsg)
      end
   end
   save(strInfoFilename,'sText','sHeader','sSearch','sPlot','sOutput','strTrunk','gScaleFactor','strWhichAx');
   % Initialize running histogram (for first in batch)
   histEdges=[-inf -100:0.1:100 inf]'; % need to scale hist bin edges
   histN=zeros(nRows(histEdges),nCols(data));
   count=0;
   save(strHistname,'histN','histEdges','count');
   % Initialize stat file (for first in batch)
   sdnIntervalStart=[];
   intervalMean=[];
   intervalRMS=[];
   intervalCount=[];
   save(strStatname,'sdnIntervalStart','intervalMean','intervalRMS','intervalCount','gScaleFactor');
end

% Update histogram
load(strHistname);
histNewN=histc(data,histEdges);
histN=histN+histNewN;
count=count+1;
save(strHistname,'histN','histEdges','count');

% Append to stats file
dataSum=sum(~isnan(data));
load(strStatname);
sdnIntervalStart=[sdnIntervalStart; sHeader.sdnDataStart];
intervalMean=[intervalMean; dataMean];
intervalRMS=[intervalRMS; dataMax];
intervalCount=[intervalCount; dataSum];
save(strStatname,'sdnIntervalStart','intervalMean','intervalRMS','intervalCount','gScaleFactor')   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sHandles] = locGenFig(t,data,sHeader,sText,sSearch,sPlot,sOutput,gScaleFactor,strWhichAx,dataMean,dataMax,strYType,numAx);

% Plot data with generic 2D plot routine

sHandles=plotgen2d(t,data,sText,sOutput.Type,[]);

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
if strcmp(sPlot.VLimMode,'auto')
   set(sHandles.AxesALL,'ylimmode','auto');
   if numAx>1
      setscalenote(sHandles.AxesALL,1);
   end
else
   set(sHandles.AxesALL,'ylimmode','manual','ylim',sPlot.VLim);
   
   %  Second part of work around, reset to previous value if
   % TLimmode set to auto and GLimMode set to manual
   if strcmp(sPlot.TLimMode,'auto') & strcmp(strWhichAx,'xyz')
      set(sHandles.AxesALL,'xlimmode','auto');
      set(sHandles.AxesALL,'xlim',TAxesLimits{1});
   end
end

str=get(sHandles.TextTitle,'str');
str=strrep(str,'Start GMT ','');
str(17:21)=[];
sdnStart=datenum(str);

hx=get(sHandles.Axes11,'xlabel');
strx=get(hx,'str');
if ~hasstr('minutes',strx)
   error('time must be in minutes')
end
tMin=get(sHandles.Line11,'xdata');
sdn=sdnStart+tMin/1440;

set(sHandles.Line11,'xdata',sdn)
set(sHandles.Axes11,'xlim',[sdn(1) sdn(end)]);
set(sHandles.Axes11,'xtick',sdn(1):1/1440:sdn(end));
dateaxis('x',13)
if ( sdn(end)-sdn(1) ) > 10/1440
   everyntix(sHandles.Axes11,2)
end
set(hx,'str','GMT (hh:mm:ss)')
set(sHandles.Axes11,'ylim',[0 100])

% Add Ronney's threshold
sHandles.LineThreshold=line([min(sdn) max(sdn)],[50 50]);
set(sHandles.LineThreshold,'color','r');

% Put name on figure
set(gcf,'Name',figname(mfilename,strWhichAx));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% revise to something like: sHandles=locMenus4leakyint(?); %
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
%   end of something like: sHandles=locMenus4leakyint(?);  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
