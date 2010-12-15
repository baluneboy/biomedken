function sHandles=intervalstat(varargin);

%intervalstat - acceleration intervals versus time
%
%sHandles=intervalstat(hDisposalFig,sDisposition); % gui syntax
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

%Author: Ken Hrovat, 2/7/2001
% $Id: intervalstat.m 4160 2009-12-11 19:10:14Z khrovat $

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
end

% Get some preliminary text
%sText.casUL=locGetTextUL(sHeader);
sText.casUR=locGetTextUR(sHeader);

switch (sPlot.IntervalFunc)
case 'average'
   sText.casUR{3} = 'Interval Average';
   strMfilename='iav';   
case 'tmf'
   sText.casUR{3} = 'Trimmed Mean Filter';
   strMfilename='itm';      
case 'minmax'
   if strcmp(sPlot.WhichAx,'vecmag')
      sText.casUR{3} = 'Interval Max';
   else
      sText.casUR{3} = 'Interval Minmax';
   end
   strMfilename='imm';
   
case 'rms'
   sText.casUR{3} = 'Root Mean Square';
   strMfilename='irm';         
end

sText.casUR{4} = sprintf('Size: %.2f,  Step: %.2f sec.',sPlot.IntervalSize,sPlot.IntervalStep);

% Remove bias intervals from ossraw, if necessary and apply bias compensation
if strcmp(sHeader.DataType,'mams_accel_ossraw');
   if (sBias.RemoveBiasPeriods==1)
      indBias = ismamsbias(data(:,6));
      data(indBias,2:5) = nan;
   end
   
   if strcmp(sBias.Action,'apply')
      [data,sHeader] = applymamsbias(data,sHeader,sBias);
   end  
   
end

% Remove bias intervals from mesaraw and apply bias compensation, if necessary
if strcmp(sHeader.DataType,'oare_accel_mesaraw');
   if (sDisposition.sBias.RemoveBiasPeriods==1)
      indBias = isoarebias(data(:,6));
      data(indBias,2:5) = nan;
   end
   
   if strcmp(sDisposition.sBias.Action,'apply')
      [data,sHeader] = applyoarebias(data,sHeader,sDisposition.sBias);
   end  
end

%   Do interval operations  and Coordinate System Transformation
%   Always do for MAMS/OARE data, but only when not Vector Magnitude for vibratory
if ( ~strcmp(sPlot.WhichAx,'vecmag')   | ~isempty(findstr(sHeader.DataType,'tmf')) | ~isempty(findstr(sHeader.DataType,'raw')))
   % compare the Name and Time, if they are different, do transformation
   if ~(strcmp(sHeader.DataCoordinateSystemName,sCoord.Name)...
         & strcmp(sHeader.DataCoordinateSystemTime,sCoord.Time))
      [data,sHeader] = transformcoord(data,sHeader,sCoord);            
      strData = sprintf('[%4.1f %4.1f %4.1f]',sHeader.DataCoordinateSystemRPY);         
      sText.casUR{2} = [sHeader.DataCoordinateSystemName strData];     
   end
else
   sText.casUR{2} = 'Vector Magnitude'; 
end

% Drop last two columns of data from raw oss
if ~isempty(findstr(sHeader.DataType,'ossraw'))
   data = data(:,1:4);
end

% Partition data & gather some text for generic call to plotgen2d
secSpan=data(end,1)-data(1,1); 
t=data(:,1); 
data(:,1)=[]; % get rid of time column
[c1,c2,c3,sText.strXType,strYType]=popdatatypes(sHeader.DataType);
clear c1 c2 c3 % just need the XType, YType, & YUnits text
strWhichAx=sPlot.WhichAx;
switch strWhichAx
case 'xyz'
   sText.casYStub={'X-Axis';'Y-Axis';'Z-Axis'}; % YLabel stubs
   data=data(:,1:3);
case 'vecmag'
   sText.casYStub={'Acceleration Vector Magnitude'};
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

% Demean data (if needed)
OrigMean=nanmean(data);
if strcmp(lower(sPlot.Demean),'yes')  
   data=data-ones(nRows(data),1)*OrigMean;
end

% Compute vector magnitude (if needed)
if strcmp('vecmag',strWhichAx)& ~strcmp('tmf',sPlot.IntervalFunc);
   data=pimsrss(data(:,1:3));
   dataMean=nanmean(data); % not original mean
   % Do the interval operations
   [t,data,sHeader,mindata] = popintervalops(t,data,sHeader,sPlot);
elseif strcmp('vecmag',strWhichAx)& strcmp('tmf',sPlot.IntervalFunc);
   % Do the interval operations
   [t,data,sHeader,mindata] = popintervalops(t,data,sHeader,sPlot);
   
   % DO Mapping Routines for quasi-steady data
   if (~isempty(findstr(sHeader.DataType,'tmf')) | ~isempty(findstr(sHeader.DataType,'raw')))
      if ~(strcmp(sHeader.SensorCoordinateSystemName, sMap.Name) &...
            strcmp(sHeader.SensorCoordinateSystemComment,sMap.Comment)); 
         sTempParam.sMap = sMap;sTempParam.sCoord=sCoord;
         
         % Temporary work around.  qsmapping had to be moved down here for raw data,
         % stick the t back on it temporarily to work in qsmapping
         [data,sHeader] = qsmapping([t data],sHeader,sTempParam,sSearch);
         % data now has t on it, remove it again
         data(:,1)=[];
         
      end
   end
   
   
   data=pimsrss(data(:,1:3));
   dataMean=nanmean(data); % not original mean
else
   % Do the interval operations
   [t,data,sHeader,mindata] = popintervalops(t,data,sHeader,sPlot);
   
   % DO Mapping Routines for quasi-steady data
   if ((~isempty(findstr(sHeader.DataType,'tmf')) | ~isempty(findstr(sHeader.DataType,'raw')))& strcmp('tmf',sPlot.IntervalFunc))
      if ~(strcmp(sHeader.SensorCoordinateSystemName, sMap.Name) &...
            strcmp(sHeader.SensorCoordinateSystemComment,sMap.Comment)); 
         sTempParam.sMap = sMap;sTempParam.sCoord=sCoord;
         % Temporary work around.  qsmapping had to be moved down here for raw data,
         % stick the t back on it temporarily to work in qsmapping
         [data,sHeader] = qsmapping([t data],sHeader,sTempParam,sSearch);
         % data now has t on it, remove it again
         data(:,1)=[];
      end
   end
   
   
end

% Get upper left text
sText.casUL=locGetTextUL(sHeader);


%Convert acceleration units (if needed)
if strcmp(sPlot.IntervalFunc,'minmax')
   [mindata]=convertunits(mindata,sHeader,sPlot);
end
[data,sHeader,tScaleFactor,strNewTUnits,gScaleFactor]=convertunits(data,sHeader,sPlot);

%[converted units] time relative to sHeader.sdnDataStart
t=t*tScaleFactor; 

% Compute RMS
dataRMS=nanrms(data);

% Get the mean of the output data
dataMean=nanmean(data);

% Get mins and maxes 
if strcmp(sPlot.IntervalFunc,'minmax')
   dataMin = nanmin(mindata); 
else   
   dataMin = nanmin(data); 
end
dataMax = nanmax(data);

% Gather rest of text for generic call to plotgen2d
numAx=nCols(data);
sText.casYTypes=repmat({strYType},numAx,1);
sText.strXUnits=sPlot.TUnits;

if strcmp(sPlot.IntervalFunc,'rms')
   strYUnits=texunits([sHeader.GUnits '_{RMS}']);
else
   strYUnits=texunits(sHeader.GUnits);
end

sText.casYUnits=repmat({strYUnits},nCols(data),1);
sText.casRS=locGetRightSideText(strWhichAx,sPlot.IntervalFunc,OrigMean,dataMean,...
   dataRMS,dataMin,dataMax,sHeader.GUnits,sHeader.DataType);
sText.strComment=strrep(strComment,'_','\_');
sText.strTitle=starttimetitle(sHeader.sdnDataStart,sSearch.PathQualifiers.strTimeBase,sSearch.PathQualifiers.strTimeFormat);
sText.strVersion=bottomdateline(sSearch.PathQualifiers.strBasePath);

% Branch on output type
strOutputType=lower(sOutput.Type);
switch strOutputType
case 'datafilebat'
   
   sHandles=[]; % no handles to return
   
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
         strMsg=evalc(['!mkdir ' strResultsPath]);
         fprintf('\npath for results: %s did not exist',strResultsPath);
         fprintf('\nmkdir returned: ( %s )',strMsg);
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
   intervalRMS=[intervalRMS; dataRMS];
   intervalCount=[intervalCount; dataSum];
   save(strStatname,'sdnIntervalStart','intervalMean','intervalRMS','intervalCount','gScaleFactor');
   
case 'imagefile'
   
   
otherwise
   % Plot data with generic 2D plot routine
   if ~strcmp('minmax',sPlot.IntervalFunc)
      sHandles=plotgen2d(t,data,sText,sOutput.Type,[]);
   else
      sHandles=plotgen2d(t,data,sText,sOutput.Type,[]);       if strcmp(strWhichAx,'xyz')
         % plot the Z min
         axes(sHandles.AxesALL(1));
         hold on;
         hzmin = plot(t,mindata(:,3),'k');
         % plot the y min
         axes(sHandles.AxesALL(2));
         hold on;
         hymin = plot(t,mindata(:,2),'k');
         % plot the x min
         axes(sHandles.AxesALL(3));
         hold on;
         hxmin = plot(t,mindata(:,1),'k');
         sHandles.LineALL = [sHandles.LineALL;hxmin;hymin;hzmin];
      elseif strcmp(strWhichAx,'vecmag')
         % Do nothing, we dont want minimum on vecmag       
      else          
         axes(sHandles.AxesALL);          
         hold on;          
         hxmin=plot(t,mindata(:,1),'k');
         sHandles.LineALL = [sHandles.LineALL;hxmin];
      end              
   end
   
   % Incorporate plot parameter settings
   
   % Get Time Axes Limit - this is part of a work around for a 
   % bug that changes the Center plots XLIM values when the 
   % YLimMode is set
   TAxesLimits = get(sHandles.AxesALL,'xlim');
   
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
   
   switch sPlot.TTickLabelMode
   case 'relative'
      % as-is should work?
   case 'dateaxis'
      setdateaxis(t,sHandles,sHeader,sPlot);
      if strcmp(sPlot.TTickForm,'hh:mm:ss')
         set(sHandles.AxesALL,'fontsize',9)
      end
   otherwise
      error('unknown TTickLabelMode')
   end
   
   
   % Nudge YLabels left where there's RMS subscript
   nudgesubscript(sHandles);
   
   set(gcf,'Name',figname(strMfilename,strWhichAx));
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % revise to something like: sHandles=locGVTmenus(?); %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
   mnuLabels=str2mat( ...
      '&View', ...
      '&Browse', ...
      strBrowseLabels, ...
      '&Options', ...
      '>&Axis', ...
      '>&NewStart', ...
      '>&Selection region'...
      );
   mnuCalls=str2mat( ...
      'disp(''View'')', ...
      '', ...
      strBrowseCalls, ...
      '', ...
      strAllAxLim, ...
      'disp(''Replot with tmin as tzero for synched currently viewed region (toss unused data, adjust header and time).'')',...
      'disp(''View selection region'')'...
      );
   sHandles.Menu=makemenu(gcf,mnuLabels,mnuCalls);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %   end of something like: sHandles=locGVTmenus(?);  %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
end

% Add print menu to figure
[hMenu,strFilename]=addprintmenu(gcf,secSpan);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casRS=locGetRightSideText(strWhichAx,strIntervalFunc,OrigMean,dataMean,dataRMS,dataMin,dataMax,strGUnits,strDataType);

if strcmp(strDataType,'mams_accel_ossraw')|strcmp(strDataType,'mams_accel_ossbtmf')
   strMean = 'Mean';
else
   strMean = 'Original Mean';
end

switch (strIntervalFunc)
case 'average'
   switch strWhichAx
   case 'xyz'
      for iCol=1:3
         casRS{iCol}{1}=sprintf([strMean ' = %.4f %s'],OrigMean(iCol),strGUnits);
         casRS{iCol}{2}=sprintf('RMS = %.4f %s',dataRMS(iCol),strGUnits);
      end
   case 'vecmag'
      casRS{1}{1}=sprintf('Mean = %.4f %s',dataMean,strGUnits);
      casRS{1}{2}=sprintf('RMS = %.4f %s',dataRMS,strGUnits);
   case {'x','y','z'}
      casRS{1}{1}=sprintf([strMean ' = %.4f %s'],OrigMean,strGUnits);
      casRS{1}{2}=sprintf('RMS = %.4f %s',dataRMS,strGUnits);
   otherwise
      strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
      error(strErr)
   end
   
case 'minmax'
   switch strWhichAx
   case 'xyz'
      for iCol=1:3
         casRS{iCol}{1}=sprintf([strMean ' = %.4f %s'],OrigMean(iCol),strGUnits);
         casRS{iCol}{2}=sprintf('Overall [Min Max]  = [%.4f %.4f] %s',dataMin(iCol),dataMax(iCol),strGUnits);
      end
   case {'x','y','z',}
      casRS{1}{1}=sprintf([strMean ' = %.4f %s'],OrigMean,strGUnits);
      casRS{1}{2}=sprintf('Overall Max  = %.4f %s',dataMax,strGUnits);
   case {'vecmag'}
      casRS{1}{1}=sprintf('Mean = %.4f %s',dataMean,strGUnits);
      casRS{1}{2}=sprintf('Overall Max  = %.4f %s',dataMax,strGUnits);
      
   otherwise
      strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
      error(strErr)
   end
   
case 'rms'
   switch strWhichAx
   case 'xyz'
      for iCol=1:3
         casRS{iCol}{1}=sprintf('Mean = %.4f %s',dataMean(iCol),strGUnits);
         casRS{iCol}{2}=sprintf('Maximum = %.4f %s',dataMax(iCol),strGUnits);
      end
   case {'x','y','z','vecmag'}
      casRS{1}{1}=sprintf('Mean = %.4f %s',dataMean,strGUnits);
      casRS{1}{2}=sprintf('Maximum = %.4f %s',dataMax,strGUnits);
   otherwise
      strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
      error(strErr)
   end
   
case 'tmf'
   switch strWhichAx
   case 'xyz'
      for iCol=1:3
         casRS{iCol}{1}=sprintf('Mean = %.4f %s',dataMean(iCol),strGUnits);
         casRS{iCol}{2}=sprintf('RMS = %.4f %s',dataRMS(iCol),strGUnits);
      end
   case 'vecmag'
      casRS{1}{1}=sprintf('Mean = %.4f %s',dataMean,strGUnits);
      casRS{1}{2}=sprintf('RMS = %.4f %s',dataRMS,strGUnits);
   case {'x','y','z'}
      casRS{1}{1}=sprintf('Mean = %.4f %s',dataMean,strGUnits);
      casRS{1}{2}=sprintf('RMS = %.4f %s',dataRMS,strGUnits);
   otherwise
      strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
      error(strErr)
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUL=locGetTextUL(sHeader);
casUL=top2textul(sHeader);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUR=locGetTextUR(sHeader);
casUR=top2textur(sHeader);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
