function sHandles=powspecdens(varargin);

%powspecdens
%
%sHandles=powspecdens(hDisposalFig,sDisposition); % gui syntax
%or
%sHandles=powspecdens(data,sHeader,sParameters,strComment); % command line
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

%Author: Ken Hrovat, 3/1/2001
% $Id: powspecdens.m 4160 2009-12-11 19:10:14Z khrovat $

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

% Get top left standard lines of ancillary text
sText.casUL=locGetTextUL(sHeader,sPlot);

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

% Generate window values
strWin=sPlot.Window;
if ~exist(strWin)
   strErr=sprintf('no window function named %s exists on path',strWin);
   error(strErr)
else
   eval(['window=' strWin '(' num2str(Nwin) ');']);
end

% Partition data
secSpan=data(end,1)-data(1,1);
data(:,1)=[]; % get rid of time column
strWhichAx=sPlot.WhichAx;
sText.strXType='Frequency';
switch strWhichAx
case 'xyz'
   sText.casYStub={'X-Axis';'Y-Axis';'Z-Axis'}; % YLabel stubs
   [data,dataMean,dataRMS]=locDemeanAndStats(data);
   [p(:,1),f,k]=psdpims(data(:,1),Nfft,fs,window,No);   
   [p(:,2),f,k]=psdpims(data(:,2),Nfft,fs,window,No);   
   [p(:,3),f,k]=psdpims(data(:,3),Nfft,fs,window,No);
case 'sum'
   sText.casYStub={'\Sigma'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data);
   [p(:,1),f,k]=psdpims(data(:,1),Nfft,fs,window,No);   
   [p(:,2),f,k]=psdpims(data(:,2),Nfft,fs,window,No);   
   [p(:,3),f,k]=psdpims(data(:,3),Nfft,fs,window,No);
   p=sum(p')';
case 'x'
   sText.casYStub={'X-Axis'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data(:,1));
   [p(:,1),f,k]=psdpims(data,Nfft,fs,window,No);   
case 'y'
   sText.casYStub={'Y-Axis'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data(:,2));
   [p(:,1),f,k]=psdpims(data,Nfft,fs,window,No);   
case 'z'
   sText.casYStub={'Z-Axis'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data(:,3));
   [p(:,1),f,k]=psdpims(data,Nfft,fs,window,No);   
otherwise
   error(sprintf('unknown axis %s',strWhichAx));
end

%fprintf('\nnumber of spectral average sections was %g\n',k)

% data gets PSD(s)
clear data
data=p;

% Gather rest of text for generic call to plotgen2d
numAx=nCols(data);
sText.casYTypes=repmat({'PSD'},numAx,1);
sText.strXUnits='Hz';
sText.casYUnits=repmat({'g^2/Hz'},nCols(data),1);
sText.casRS={};%FOR NOW, BUT WAS: locGetRightSideText(strWhichAx,f,data,fc);
sText.strComment=strComment;
% moved casUL up before transformation from here
strSpan=sprintf('Span = %.2f sec.',secSpan);
sText.casUR=locGetTextUR(sHeader,sPlot,k,strSpan);
sText.strTitle=starttimetitle(sHeader.sdnDataStart,sSearch.PathQualifiers.strTimeBase,sSearch.PathQualifiers.strTimeFormat);
sText.strVersion=bottomdateline(sSearch.PathQualifiers.strBasePath);

% Branch on output type
strOutputType=lower(sOutput.Type);
switch strOutputType
case 'datafilebat'    
   
   disp('temp Jules usage of this part for now')
   
   sHandles=[]; % no handles to return
   
   % Path for results
   strResultsPath=sDisposition.ResultsPath;
   strUnique=sDisposition.UniqueString;
   strTrunk=[strResultsPath strUnique '_'];
   
   strTempFile=['T:\www\requests\Jules\' strrep(popdatestr(sHeader.sdnDataStart,-2),':','_')];
   strTempFile(end-3:end)=[];
   strTempFile=[strTempFile '_' sHeader.SensorID '_psd3.csv'];
   csvwrite(strTempFile,[f data])
   
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
   sHandles=plotgen2d(f,data,sText,sOutput.Type,[]);
   
   % Incorporate plot parameter settings
   strPLimMode=sPlot.PLimMode;
   switch strPLimMode
   case 'manual' % set limits
      % use as-is
   case 'hist' % calculate histogram
      edges=[-inf -20:0.1:0 inf];
      n=histc(log10(b(:)),edges);
      figure
      edges(1)=nan;edges(end)=nan;
      plot(edges,n),xlabel('edges'),ylabel('n'),title('clim hist')
   case 'auto'
      ind=find(f<=FLim(2));
      tmp=data(ind,:);
      pmin=nanmin(tmp(:));
      pmax=nanmax(tmp(:));
      clear tmp
      sPlot.PLim=[pmin/2 2*pmax];
   otherwise
      strErr=sprintf('unknown PLimMode %s',strPLimMode);
      error(strErr)
   end % switch PLimMode
   set(sHandles.AxesALL,'yscale','log','ylim',sPlot.PLim);
   
   if strcmp(sPlot.FLimMode,'auto')
      set(sHandles.AxesALL,'xlim',[0 fc]);
   else
      set(sHandles.AxesALL,'xlimmode','manual','xlim',sPlot.FLim);
   end
   
   set(gcf,'Name',figname('psd',strWhichAx));
   
   [hMenu,strFilename]=addprintmenu(gcf,secSpan);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % revise to something like: sHandles=locCrammenus(?); %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Need to modularize these specialized menus where possible
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,dataMean,dataRMS]=locDemeanAndStats(data);

% Compute mean of data
dataMean=nanmean(data);

% Demean data
data=data-ones(nRows(data),1)*dataMean;

% Compute RMS of data
dataRMS=nanrms(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casRS=locGetRightSideText(strWhichAx,f,data,fc);
% RMS (f1 to f2 Hz) = %g (g) [cumf,grms]=cumrms(f,data,fc,[(f(2) fc],'table');
% Peak: 1e-5 @ 20 Hz, 2e-7 @ 32 Hz
switch strWhichAx
case 'xyz'
   for iCol=1:3
      [cumf,grms]=cumrms(f,data(:,iCol),fc,[f(2) fc],'table');
      ind=find(f>=f(2) & f<=fc);
      [dataPeak,indPeak]=max(data(ind,iCol));
      freqPeak=f(indPeak);
      casRS{iCol}{1}=sprintf('RMS (%.2f-%.2f Hz) = %.2e (g)',f(2),fc,grms);
      casRS{iCol}{2}=sprintf('Peak: %.2e g^2/Hz at %.2f Hz',dataPeak,freqPeak);
   end
case {'sum','x','y','z'}
   [cumf,grms]=cumrms(f,data,fc,[f(2) fc],'table');
   ind=find(f>=f(2) & f<=fc);
   [dataPeak,indPeak]=max(data);
   freqPeak=f(indPeak);
   casRS{1}{1}=sprintf('RMS (%.2f-%.2f Hz) = %.2e (g)',f(2),fc,grms);
   casRS{1}{2}=sprintf('Peak: %.2e g^2/Hz at %.2f Hz',dataPeak,freqPeak);
otherwise
   strErr=sprintf('unrecognized WhichAx string: %s',strWhichAx);
   error(strErr)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUL=locGetTextUL(sHeader,sPlot);
fs=sHeader.SampleRate;
Nfft=sPlot.Nfft;
No=sPlot.No;
casUL=top2textul(sHeader);
casUL{3}=sprintf('\\Deltaf = %.3f Hz,  Nfft = %d',fs/Nfft,Nfft);
casUL{4}=sprintf('P = %.1f%%,  No = %d',100*No/Nfft,No);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUR=locGetTextUR(sHeader,sPlot,k,strSpan);
casUR=top2textur(sHeader);
if strcmp(sPlot.WhichAx,'sum')
   casUR{2} = 'Sum';
end
strWindow=[upper(sPlot.Window(1)) sPlot.Window(2:end)];
casUR{3}=sprintf('%s, k = %g',strWindow,k);
casUR{4}=strSpan; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [b,f,t]=locComputePSD(x,nfft,fs,window,noverlap);
[b,f,t]=psdpims(x,nfft,fs,window,noverlap);