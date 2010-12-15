function sHandles=rmsbvt(varargin);

%rmsbvt
%
%sHandles=rmsbvt(hDisposalFig,sDisposition); % gui syntax
%or
%sHandles=rmsbvt(data,sHeader,sParameters,strComment); % command line
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

%Author: Ken Hrovat, 3/19/2001
%$Id: rmsbvt.m 4160 2009-12-11 19:10:14Z khrovat $

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
case 4 % command line call
   [data,sHeader,sParameters,strComment]=deal(varargin{:});
   sSearch=sParameters.sSearchCriteria;
   sPlot=sParameters.sPlot;
   sOutput=sParameters.sOutput;
otherwise
   error('wrong nargin')
end

% Apply coordinate system transform (if needed)
if ~strcmp(sPlot.WhichAx,'sum')
   [data,sHeader,casCoordinateSys]=locReplaceWithEKtransform(data,sHeader);
else
   casCoordinateSys='getCoordSysFromHeader';
end

% Convert acceleration units (if needed)
[data,sHeader,tScaleFactor]=locReplaceWithEKconvert(data,sHeader,sPlot.TUnits,'g');

% Gather parameters for pimsspecgram
fs=sHeader.SampleRate;
fc=sHeader.CutoffFreq;
Nfft=sPlot.Nfft;
Nwin=Nfft;
No=sPlot.No;
RLim=sPlot.RLim;

% Generate window values
strWin=sPlot.Window;
if ~exist(strWin)
   strErr=sprintf('no window function named %s exists on path',strWin);
   error(strErr)
else
   eval(['window=' strWin '(' num2str(Nwin) ');']);
end

% Partition data
timeSpan=data(end,1)-data(1,1);
data(:,1)=[]; % get rid of time column
strWhichAx=sPlot.WhichAx;
sText.strXType='Time';
switch strWhichAx
case 'xyz'
   sText.casYStub={'X-Axis';'Y-Axis';'Z-Axis'}; % YLabel stubs
   [data,dataMean,dataRMS]=locDemeanAndStats(data);
   [b(:,:,1),f,t]=pimsspecgram(data(:,1),Nfft,fs,window,No);   
   [b(:,:,2),f,t]=pimsspecgram(data(:,2),Nfft,fs,window,No);   
   [b(:,:,3),f,t]=pimsspecgram(data(:,3),Nfft,fs,window,No);
case 'sum'
   sText.casYStub={''};
   [data,dataMean,dataRMS]=locDemeanAndStats(data);
   [bx,f,t]=pimsspecgram(data(:,1),Nfft,fs,window,No);   
   [by,f,t]=pimsspecgram(data(:,2),Nfft,fs,window,No);   
   [bz,f,t]=pimsspecgram(data(:,3),Nfft,fs,window,No);
   b=bx+by+bz;
   clear bx by bz
case 'x'
   sText.casYStub={'X-Axis'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data(:,1));
   [b,f,t]=pimsspecgram(data,Nfft,fs,window,No);   
case 'y'
   sText.casYStub={'Y-Axis'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data(:,2));
   [b,f,t]=pimsspecgram(data,Nfft,fs,window,No);   
case 'z'
   sText.casYStub={'Z-Axis'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data(:,3));
   [b,f,t]=pimsspecgram(data,Nfft,fs,window,No);   
otherwise
   error(sprintf('unknown axis %s',strWhichAx));
end
clear data

% Call for frequency ranges
eval(['freq_ranges=' sPlot.BandFile ';'])
numRanges=nRows(freq_ranges);

% Calculate RMS values for all bands
[bandrms,numBands,numPSDs,numT]=calcbandrms(f,b,fc,freq_ranges);

% Gather text
numAx=nCols(bandrms);
strYType='RMS Acceleration';
sText.casYTypes=repmat({strYType},numAx,1);
sText.casYUnits=repmat({[sHeader.Units '_{RMS }']},numAx,1);
sText.strXUnits=sPlot.TUnits;
sText.strComment=strComment;
sText.casUR=locGetTextUR(sHeader,sPlot,numPSDs);
sText.casRS=locGetRightSideText(strWhichAx,dataMean,dataRMS,sHeader.Units);
sText.strTitle=starttimetitle(sHeader.sdnDataStart,sSearch.PathQualifiers.strTimeBase,sSearch.PathQualifiers.strTimeFormat);
sText.strVersion=bottomdateline(sSearch.PathQualifiers.strBasePath);

% Branch on output type
if strcmp(sOutput.Type,'datafilebat')
   % Build path
   strTrunk=[sOutput.Basepath sHeader.SensorID filesep 'rmsbvt' filesep strComment '_'];
   % Save info file (if needed)
   strInfoFilename=[strTrunk 'info.mat'];
   if ~exist(strInfoFilename)
      spanSec=(t(end)-t(1))*units('seconds');
      numCat=round(double(sPlot.TSpan*units(sPlot.TUnits)/spanSec));
      save(strInfoFilename,'f','sText','sHeader','sSearch','sPlot','sOutput','strTrunk','numCat');
      % Initialize running color limit histogram (if needed)
      if strcmp(strCLimMode,'hist')
         strHistname=[strTrunk 'hist.mat'];
         histEdges=[-inf -20:0.1:0 inf]; % log base 10
         histN=zeros(size(histEdges));
         count=0;
         save(strHistname,'histN','histEdges','count');
      end
   end
   % Save data file
   strFilename=strrep(popdatestr(sHeader.sdnDataStart,-3.1),'.','_');
   t=t(:)'./86400+sHeader.sdnDataStart;
   save([strTrunk strFilename],'b','t');
   % Update histogram for color limits (if needed)
   if strcmp(strCLimMode,'hist')
      strHistname=[strTrunk 'hist.mat'];
      load(strHistname)
      histNewN=histc(log10(b(:)),histEdges);
      histN=histN+histNewN(:)';
      count=count+1;
      save(strHistname,'histN','histEdges','count');
   end
else
   % Put time in desired units
   t=t*tScaleFactor;
   % Loop for frequency bands
   for iBand=1:numBands
      frange=freq_ranges(iBand,:);
      grms=bandrms(:,:,iBand);
      
      % Add freq. range to UL text
      sPlot.FreqRange=frange;
      sText.casUL=locGetTextUL(sHeader,sPlot);

      % Plot data with generic 2D plot routine
      sHandles=plotgen2d(t,grms,sText,sOutput.Type,[]);
      
      % Incorporate plot parameter settings
      if strcmp(sPlot.TLimMode,'auto')
         set(sHandles.AxesALL,'xlimmode','auto');
      else
         set(sHandles.AxesALL,'xlimmode','manual','xlim',sPlot.TLim);
      end
      set(sHandles.AxesALL,'ylimmode','auto');
      
      set(gcf,'Name',[mfilename strWhichAx]);
      
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,dataMean,dataRMS]=locDemeanAndStats(data);

% Compute mean of data
dataMean=nanmean(data);

% Demean data
data=data-ones(nRows(data),1)*dataMean;

% Compute RMS of data
dataRMS=nanrms(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casRS=locGetRightSideText(strWhichAx,dataMean,dataRMS,strGUnits);
switch strWhichAx
case 'xyz'
   for iCol=1:3
      casRS{iCol}{1}=sprintf('Original Mean = %.4f %s',dataMean(iCol),strGUnits);
      casRS{iCol}{2}=sprintf('RMS = %.4f %s',dataRMS(iCol),strGUnits);
   end
case 'sum'
   casRS{1}{1}=sprintf('Mean = %.4f %s',dataMean,strGUnits);
   casRS{1}{2}=sprintf('RMS = %.4f %s',dataRMS,strGUnits);
case {'x','y','z'}
   casRS{1}{1}=sprintf('Original Mean = %.4f %s',dataMean,strGUnits);
   casRS{1}{2}=sprintf('RMS = %.4f %s',dataRMS,strGUnits);
otherwise
   strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
   error(strErr)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUL=locGetTextUL(sHeader,sPlot);
fs=sHeader.SampleRate;
Nfft=sPlot.Nfft;
No=sPlot.No;
f1=sPlot.FreqRange(1);
f2=sPlot.FreqRange(2);
casUL=top2textul(sHeader);
casUL{3}=sprintf('\\Deltaf: %.3f Hz, Range: %g - %g Hz',fs/Nfft,f1,f2);
casUL{4}=sprintf('Temp. Resolution: %.3f sec',(Nfft-No)/fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUR=locGetTextUR(sHeader,sPlot,numPSDs);
casUR=top2textur(sHeader);
strWindow=[upper(sPlot.Window(1)) sPlot.Window(2:end)];
casUR{3}=sprintf('%s, k = %g',strWindow,numPSDs);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [b,f,t]=locComputeSpecgram(x,nfft,fs,window,noverlap);
[b,f,t]=pimsspecgram(x,nfft,fs,window,noverlap);