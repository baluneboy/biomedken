function [hFig,hAx,hText]=time_series(data,sHeader,sParameters,varargin);
%sHandles=plottype(hDisposalFig,sDisposition); % gui syntax

%TIME_SERIES - function to generate time series using specified parameters
%
%[hfig,hax,htext]=time_series(data,sHeader,sParameters,varargin);
%
%Inputs: data - matrix of [t x y z maybe_s] columns
%        sHeader - structure of header info
%        sParameters - nested structure of .plot, .output, .other? parameters
%
%Outputs: hFig - scalar figure handle
%         hAx - vector of axes handles
%         hText - vector of text handles

h=guidata(hDisposalFig);
data=h.data;
sdnStartData=data(1,1);
sHeader=h.sHeader;
sSearch=h.sSearchCriteria;
sPlot=sDisposition.sPlot;
sOutput=sDisposition.sOutput;

% Boolean for demean
blnDemean=strcmp(lower(sDisposition.sPlot.Demean),'yes');

% Apply coord. sys. transform and convert units (if needed)
[data,sHeader,casCoordinateSys]=locReplaceWithEK(data,sHeader);

% Gather plot text for generic call to plotgen2d
[c1,c2,c3,sText]=popdatatypes; clear c1 c2 c3 % just need the XType, YType, & YUnits text
sText.strXUnits=sPlot.TUnits;
sText.casYUnits={sHeader.Units};
[data,sText.casYStub,sText.casRS]=locGetYVals(data,sPlot.WhichAx,sHeader.Units);
sText.strComment=sDisposition.strComment;
sText.casUL=locGetTextUL(sHeader);
sText.casUR={'Increment # from lookup',casCoordinateSys};
sText.strTitle=locGetTimeTitle(sdnStartData,sSearch);
sText.strVersion='How do we get version?';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[data,sHeader,casCoordinateSys]=locReplaceWithEK(data,sHeader);
data(:,2:end)=data(:,2:end)*1e3;
sHeader.Units='milli-g';
casCoordinateSys=sprintf('casCoordinateSys from (EK)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,casYStub,casRS]=locGetYVals(data,blnDemean,strWhichAx,strYUnits);
switch strWhichAx
case 'x'
   iCol=2;
   casYStub={'X-Axis'};
   data=[data(:,1) data(:,iCol)];
   casRS{1}=sprintf('Original Mean = %g %s',mean(data(:,2)));
   casRS{2}=sprintf('    RMS Value = %g %s',mean(data(:,2)));
case 'y'
   iCol=3;
   casYStub={'Y-Axis'};
   data=[data(:,1) data(:,iCol)];
   casRS{1}=sprintf('Original Mean = %g %s',mean(data(:,2)));
   casRS{2}=sprintf('    RMS Value = %g %s',rms(data(:,2)));
case 'z'
   iCol=4;
   casYStub={'Z-Axis'};
   data=[data(:,1) data(:,iCol)];
   casRS{1}=sprintf('Original Mean = %g %s',mean(data(:,2)));
   casRS{2}=sprintf('    RMS Value = %g %s',rms(data(:,2)));
case 'xyz'
   casYStub={'X-Axis','Y-Axis','Z-Axis'};
   for iCol=2:4
      casRS{iCol-1}{1}=sprintf('Original Mean = %g %s',mean(data(:,iCol)));
      casRS{iCol-1}{2}=sprintf('    RMS Value = %g %s',rms(data(:,iCol)));
   end
case 'vecmag'
   iCol=2:4;
   data=[data(:,1) pimsrss(data(:,iCol))];
   casYStub={'Vector Magnitude'};
   casRS{1}=sprintf('   Mean Value = %g %s',mean(data(:,iCol)));
   casRS{2}=sprintf('    RMS Value = %g %s',rms(data(:,iCol)));
otherwise
   strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
   error(strErr)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,casYStub,casRS]=locGetYVals(data,strWhichAx,strYUnits);
switch strWhichAx
case 'x'
   iCol=2;
   casYStub={'X-Axis'};
   data=[data(:,1) data(:,iCol)];
   casRS{1}=sprintf('Original Mean = %g %s',mean(data(:,2)));
   casRS{2}=sprintf('    RMS Value = %g %s',mean(data(:,2)));
case 'y'
   iCol=3;
   casYStub={'Y-Axis'};
   data=[data(:,1) data(:,iCol)];
   casRS{1}=sprintf('Original Mean = %g %s',mean(data(:,2)));
   casRS{2}=sprintf('    RMS Value = %g %s',rms(data(:,2)));
case 'z'
   iCol=4;
   casYStub={'Z-Axis'};
   data=[data(:,1) data(:,iCol)];
   casRS{1}=sprintf('Original Mean = %g %s',mean(data(:,2)));
   casRS{2}=sprintf('    RMS Value = %g %s',rms(data(:,2)));
case 'xyz'
   casYStub={'X-Axis','Y-Axis','Z-Axis'};
   for iCol=2:4
      casRS{iCol-1}{1}=sprintf('Original Mean = %g %s',mean(data(:,iCol)));
      casRS{iCol-1}{2}=sprintf('    RMS Value = %g %s',rms(data(:,iCol)));
   end
case 'vecmag'
   iCol=2:4;
   data=[data(:,1) pimsrss(data(:,iCol))];
   casYStub={'Vector Magnitude'};
   casRS{1}=sprintf('   Mean Value = %g %s',mean(data(:,iCol)));
   casRS{2}=sprintf('    RMS Value = %g %s',rms(data(:,iCol)));
otherwise
   strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
   error(strErr)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUL=locGetTextUL(sHeader);
strDataType=sHeader.DataType;
strLocation=sHeader.DataCoordinateSystemName;
sampleRate=sHeader.SampleRate;
cutoffFreq=sHeader.CutoffFreq;
iDash=findstr(strDataType,'-');
if isempty(iDash)
   strSys='WHICH SYS?';
else
   strSys=upper(strDataType(1:iDash-1);
end
casUL{1}=sprintf('%s, %s',strSys,strLocation);
casUL{2}=sprintf('%.1f sa/sec (%.1f Hz)',sampleRate,cutoffFreq);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strTitle=locGetTimeTitle(sdnStartData,sSearch);
strTimeBase=sSearch.PathQualifiers.strTimeBase;
strTimeFormat=sSearch.PathQualifiers.strTimeFormat;
strTime=popdatestr(sdnStartData,strTimeFormat);
strTitle=sprintf('Start %s %s',strTimeBase,strTime);