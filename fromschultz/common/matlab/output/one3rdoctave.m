function sHandles=one3rdoctave(varargin);

%one3rdoctave
%
%sHandles=one3rdoctave(hDisposalFig,sDisposition); % gui syntax
%or
%sHandles=one3rdoctave(data,sHeader,sParameters,strComment); % command line
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

%Author: Ken Hrovat, 3/15/2001
% $Id: one3rdoctave.m 4160 2009-12-11 19:10:14Z khrovat $

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
   sCoord = sDisposition.sCoord;
   strComment=sDisposition.strComment;
case 4 % command line call
   [data,sHeader,sParameters,strComment]=deal(varargin{:});
   sSearch=sParameters.sSearchCriteria;
   sPlot=sParameters.sPlot;
   sOutput=sParameters.sOutput;
   if isfield(sParameters,'sCoord');
      sCoord = sParameters.sCoord;
   end
otherwise
   error('wrong nargin')
end

% Coordinate System Transformation
if ~strcmp(sPlot.WhichAx,'sum')
% compare the Name and Time, if they are different, do transformation
   if ~(strcmp(sHeader.DataCoordinateSystemName,sCoord.Name)...
         & strcmp(sHeader.DataCoordinateSystemTime,sCoord.Time))
      [data,sHeader] = transformcoord(data,sHeader,sCoord);
   end
end

% No convert acceleration units here; not needed because PSD does not have GUnits or TUnits

% Gather parameters for psdpims
fs=sHeader.SampleRate;
fc=sHeader.CutoffFreq;
Nfft=sPlot.Nfft;
Nwin=Nfft;
No=sPlot.No;
FLim=sPlot.FLim;

% Partition data
secSpan=data(end,1)-data(1,1);
data(:,1)=[]; % get rid of time column
strWhichAx=sPlot.WhichAx;
strWindow=sPlot.Window;
otoMode=sPlot.Mode;
sText.strXType='One-Third Octave Frequency Bands';
switch strWhichAx
case 'xyz'
   sText.casYStub={'X-Axis';'Y-Axis';'Z-Axis'}; % YLabel stubs
   [foto,grms,deltaf,k]=locComputeOTOxyz(data,fs,fc,strWindow,otoMode,Nfft,No);
case 'sum'
   sText.casYStub={''};
   [foto,grms,deltaf,k]=locComputeOTOxyz(data,fs,fc,strWindow,otoMode,Nfft,No);
   grms=pimsrss(grms);
case 'x'
   sText.casYStub={'X-Axis'};
   [foto,grms(:,1),deltaf,k]=oto(data(:,1),fs,fc,strWindow,otoMode,Nfft,No);
case 'y'
   sText.casYStub={'Y-Axis'};
   [foto,grms(:,1),deltaf,k]=oto(data(:,2),fs,fc,strWindow,otoMode,Nfft,No);
case 'z'
   sText.casYStub={'Z-Axis'};
   [foto,grms(:,1),deltaf,k]=oto(data(:,3),fs,fc,strWindow,otoMode,Nfft,No);
otherwise
   error(sprintf('unknown axis %s',strWhichAx));
end

% data gets grms levels
clear data
data=grms;

% Gather rest of text for generic call to plotgen2d
numAx=nCols(data);
sText.casYTypes=repmat({'RMS Acceleration'},numAx,1);
sText.strXUnits='Hz';
sText.casYUnits=repmat({'g_{ RMS }'},nCols(data),1);
sText.casRS=locGetRightSideText(strWhichAx,foto,data,fc);
sText.strComment=strComment;
sText.casUL=locGetTextUL(sHeader,sPlot);
strSpan=sprintf('Span = %.2f sec.',secSpan);
sText.casUR=locGetTextUR(sHeader,sPlot,k,strSpan);
sText.strTitle=starttimetitle(sHeader.sdnDataStart,sSearch.PathQualifiers.strTimeBase,sSearch.PathQualifiers.strTimeFormat);
sText.strVersion=bottomdateline(sSearch.PathQualifiers.strBasePath);

% Branch on output type
strOutputType=lower(sOutput.Type);
switch strOutputType
case 'datafilebat'    
   
   disp('temp Christoffersen usage of this part for now')
   
   sHandles=[]; % no handles to return
   
   % Path for results
   strResultsPath=sDisposition.ResultsPath;
   strUnique=sDisposition.UniqueString;
   strTrunk=[strResultsPath strUnique '_'];
   
   strTempFile=['T:\www\requests\Christoffersen\' strrep(popdatestr(sHeader.sdnDataStart,-2),':','_')];
   strTempFile(end-3:end)=[];
   strTempFile=[strTempFile '_' sHeader.SensorID '_otos.csv'];
   csvwrite(strTempFile,[foto data])
   
   return % NOTE: below this was copied from gvt, just temp usage now above
   
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
   intervalRMS=[intervalRMS; dataRMS];
   intervalCount=[intervalCount; dataSum];
   save(strStatname,'sdnIntervalStart','intervalMean','intervalRMS','intervalCount','gScaleFactor');
   
case 'imagefile'
   
otherwise
   
   % Plot data with generic 2D plot routine
   sHandles=plotgen2d(foto,data,sText,sOutput.Type,[]);
   
   % Add ISS requirements curve
   sHandles=issoverlay(sHandles,sPlot.ISScolor,sPlot.ISSstyle,sPlot.ISSwidth);
   
   % Incorporate plot parameter settings
   strRLimMode=sPlot.RLimMode;
   switch strRLimMode
   case 'manual'
      % as-is
   case 'auto'
      rmin=nanmin([1.6e-6; data(:)]);
      rmax=nanmax([1600e-6; data(:)]);
      sPlot.RLim=[rmin/2 1.875*rmax];
   otherwise
      strErr=sprintf('unknown RLimMode %s',strRLimMode);
      error(strErr)
   end % switch RLimMode
   set(sHandles.AxesALL,'xscale','log','yscale','log','ylim',sPlot.RLim);
   
   if strcmp(sPlot.FLimMode,'auto')
      set(sHandles.AxesALL,'xlim',[0.01 300]);
   else
      set(sHandles.AxesALL,'xlimmode','manual','xlim',sPlot.FLim);
   end
   
   set(gcf,'Name',[mfilename strWhichAx]);
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casRS=locGetRightSideText(strWhichAx,f,data,fc);
casRS={}; return % for now
switch strWhichAx
case 'xyz'
   for iCol=1:3
      [ug,atf]=locTwoLoudest(f,data(:,iCol));
      casRS{iCol}{1}=sprintf('%g < f < %g Hz, %0.1f \\mug_{RMS}',atf(1,:),ug(1));
      casRS{iCol}{2}=sprintf('%g < f < %g Hz, %0.1f \\mug_{RMS}',atf(2,:),ug(2));
   end
case {'sum','x','y','z'}
   [ug,atf]=locTwoLoudest(f,data);
   casRS{1}{1}=sprintf('%g < f < %g Hz, %0.1f \\mug_{RMS}',atf(1,:),ug(1));
   casRS{1}{2}=sprintf('%g < f < %g Hz, %0.1f \\mug_{RMS}',atf(2,:),ug(2));
otherwise
   strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
   error(strErr)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUL=locGetTextUL(sHeader,sPlot);
fs=sHeader.SampleRate;
Nfft=sPlot.Nfft;
%No=sPlot.No;
casUL=top2textul(sHeader);
casUL{3}=sprintf('\\Deltaf = %.3f Hz,  Nfft = %d',fs/Nfft,Nfft);
casUL{4}=sprintf('Mode: %s',sPlot.Mode);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUR=locGetTextUR(sHeader,sPlot,k,strSpan);
casUR=top2textur(sHeader);
if strcmp(sPlot.WhichAx,'sum')
   casUR{2} = 'Sum';
end
strWindow=[upper(sPlot.Window(1)) sPlot.Window(2:end)];
casUR{3}=sprintf('%s, k = %g',strWindow,k);
casUR{4}=strSpan; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,sHeader,casCoordinateSys]=locReplaceWithEKtransform(data,sHeader);
disp('use transform function from EK')
casCoordinateSys='casCoordSysFromEK';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,sHeader,tScaleFactor]=locReplaceWithEKconvert(data,sHeader,strTUnits,strGUnits);
disp('use convert function from EK (header.Units field must be updated to reflect conversion)')
tScaleFactor=double(convert(1*units('seconds'),strTUnits));
switch strGUnits
case 'g'
   sHeader.Units=' g ';
case 'millig'
   sHeader.Units=' mg ';
case 'microg'
   sHeader.Units=' \mug ';
otherwise
   error('unknown g units %s',strGUnits);
end % switch strGUnits

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [foto,grms,deltaf,k]=locComputeOTOxyz(data,fs,fc,strWindow,otoMode,Nfft,No);
for ix=1:3
   [foto,grms(:,ix),deltaf,k]=oto(data(:,ix),fs,fc,strWindow,otoMode,Nfft,No);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ug,atf]=locTwoLoudest(foto,dataColumn);
[sortedData,iSort]=sort(dataColumn);
foto=foto(iSort);
% get rid of NaNs
iNaN=find(isnan(sortedData));
foto(iNaN)=[];
sortedData(iNaN)=[];
ug(1)=sortedData(end)/1e-6;
atf(1,:)=[foto(end-1) foto(end)];
ug(2)=sortedData(end-2)/1e-6;
atf(2,:)=[foto(end-3) foto(end-2)];
