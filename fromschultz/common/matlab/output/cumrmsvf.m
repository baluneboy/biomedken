function sHandles=cumrmsvf(varargin);

%cumrmsvf
%
%sHandles=cumrmsvf(hDisposalFig,sDisposition); % gui syntax
%or
%sHandles=cumrmsvf(data,sHeader,sParameters,strComment); % command line
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

%Author: Ken Hrovat, 3/16/2001
%$Id: cumrmsvf.m 4160 2009-12-11 19:10:14Z khrovat $

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

% Convert acceleration units (if needed)
%[data,sHeader,tScaleFactor]=locReplaceWithEKconvert(data,sHeader,'minutes','g');

% Convert acceleration units (if needed)
sPlot.TUnits = 'minutes';
sPlot.GUnits = 'g';
[data(:,2:end),sHeader,tScaleFactor,strNewTUnits,gScaleFactor]=convertunits(data(:,2:end),sHeader,sPlot);

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
   [f,c,k]=locComputeCumRMSxyz(data,Nfft,fs,window,No,fc);   
case 'sum'
   %fprintf('\nNeeds closer look, too low quick look.\n')
   sText.casYStub={'\Sigma'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data);
   [f,c,k]=locComputeCumRMSsum(data,Nfft,fs,window,No,fc);
case 'x'
   sText.casYStub={'X-Axis'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data(:,1));
   [f,c(:,1),k]=locComputeCumRMS(data,Nfft,fs,window,No,fc);
case 'y'
   sText.casYStub={'Y-Axis'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data(:,2));
   [f,c(:,1),k]=locComputeCumRMS(data,Nfft,fs,window,No,fc);
case 'z'
   sText.casYStub={'Z-Axis'};
   [data,dataMean,dataRMS]=locDemeanAndStats(data(:,3));
   [f,c(:,1),k]=locComputeCumRMS(data,Nfft,fs,window,No,fc);
otherwise
   error(sprintf('unknown axis %s',strWhichAx));
end

% data gets PSD(s)
clear data
data=c;

% Gather rest of text for generic call to plotgen2d
numAx=nCols(data);
sText.casYTypes=repmat({'Cumulative RMS'},numAx,1);
sText.strXUnits='Hz';
sText.casYUnits=repmat({'g_{ RMS }'},nCols(data),1);
sText.casRS=locGetRightSideText(strWhichAx,f,data,fc);
sText.strComment=strComment;
sText.casUL=locGetTextUL(sHeader,sPlot);
strSpan=sprintf('Span = %.2f sec.',secSpan);
sText.casUR=locGetTextUR(sHeader,sPlot,k,strSpan);
sText.strTitle=starttimetitle(sHeader.sdnDataStart,sSearch.PathQualifiers.strTimeBase,sSearch.PathQualifiers.strTimeFormat);
sText.strVersion=bottomdateline(sSearch.PathQualifiers.strBasePath);

% Plot data with generic 2D plot routine
sHandles=plotgen2d(f,data,sText,sOutput.Type,[]);

% Incorporate plot parameter settings
strPLimMode=sPlot.PLimMode;
switch strPLimMode
case 'minmax' % set limits
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
set(sHandles.AxesALL,'ylim',sPlot.PLim);

if strcmp(sPlot.FLimMode,'auto')
   set(sHandles.AxesALL,'xlim',[0 fc]);
else
   set(sHandles.AxesALL,'xlimmode','manual','xlim',sPlot.FLim);
end

set(gcf,'Name',[mfilename strWhichAx]);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % revise to something like: sHandles=locComputepsdpimstrogrammenus(?); %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Need to modularize these specialized menus where possible
% casBrowseLabels=strcat(strrep(sText.casYStub,'-','_'),['_' sHeader.Units]);
% casBrowseLabels=strrep(casBrowseLabels,' ','');
% %loadsptool(b,sHeader.SampleRate,casBrowseLabels)
% switch strWhichAx
% case 'xyz'
%    strGetData=[      'data=get(' num2str(sHandles.Line11,22)...
%          ',''ydata'')'';data=[data get(' num2str(sHandles.Line21,22)...
%          ',''ydata'')''];data=[data get(' num2str(sHandles.Line31,22) ',''ydata'')''];'];
%    strRest=[num2str(sHeader.SampleRate,22) ',{''' casBrowseLabels{1} ''',''' casBrowseLabels{2} ''',''' casBrowseLabels{3} '''});'];
%    strBrowseLabels='>XYZ';
%    strBrowseCalls=[strGetData 'loadsptool(data,' strRest];
% case 'vecmag'
%    strGetData=[      'data=get(' num2str(sHandles.Line11,22) ',''ydata'')'';'];
%    strRest=[num2str(sHeader.SampleRate,22) ',{''' casBrowseLabels{1} '''});'];
%    strBrowseLabels='>VecMag';
%    strBrowseCalls=[strGetData 'loadsptool(data,' strRest];
% case 'x'
%    strGetData=[      'data=get(' num2str(sHandles.Line11,22) ',''ydata'')'';'];
%    strRest=[num2str(sHeader.SampleRate,22) ',{''' casBrowseLabels{1} '''});'];
%    strBrowseLabels='>X';
%    strBrowseCalls=[strGetData 'loadsptool(data,' strRest];
% case 'y'
%    strGetData=[      'data=get(' num2str(sHandles.Line11,22) ',''ydata'')'';'];
%    strRest=[num2str(sHeader.SampleRate,22) ',{''' casBrowseLabels{1} '''});'];
%    strBrowseLabels='>Y';
%    strBrowseCalls=[strGetData 'loadsptool(data,' strRest];
% case 'z'
%    strGetData=[      'data=get(' num2str(sHandles.Line11,22) ',''ydata'')'';'];
%    strRest=[num2str(sHeader.SampleRate,22) ',{''' casBrowseLabels{1} '''});'];
%    strBrowseLabels='>Z';
%    strBrowseCalls=[strGetData 'loadsptool(data,' strRest];
% otherwise
%    error(sprintf('unknown axis %s',strWhichAx));
% end
% strAllAxLim=allaxlimdlg(sHandles.AxesALL,sText.strXType,strYType);
% mnuLabels=str2mat( ...
%    '&View', ...
%    '&Browse', ...
%    strBrowseLabels, ...
%    '&Options', ...
%    '>&Axis', ...
%    '>&NewStart', ...
%    '>&Selection region'...
%    );
% mnuCalls=str2mat( ...
%    'disp(''View'')', ...
%    '', ...
%    strBrowseCalls, ...
%    '', ...
%    strAllAxLim, ...
%    'disp(''Replot with tmin as tzero for synched currently viewed region (toss unused data, adjust header and time).'')',...
%    'disp(''View selection region'')'...
%    );
% sHandles.Menu=makemenu(gcf,mnuLabels,mnuCalls);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %   end of something like: sHandles=locComputepsdpimstrogrammenus(?);  %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
casRS={};return
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,c,k]=locComputeCumRMS(data,Nfft,fs,window,No,fc);
[p,f,k]=psdpims(data,Nfft,fs,window,No);
[f,c]=cumrms(f,p,fc,[],'sections');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,c,k]=locComputeCumRMSxyz(data,Nfft,fs,window,No,fc);
for i=1:3
   [f,c(:,i),k]=locComputeCumRMS(data(:,i),Nfft,fs,window,No,fc);   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,c,k]=locComputeCumRMSsum(data,Nfft,fs,window,No,fc);
[p(:,1),f,k]=psdpims(data(:,1),Nfft,fs,window,No);   
[p(:,2),f,k]=psdpims(data(:,2),Nfft,fs,window,No);   
[p(:,3),f,k]=psdpims(data(:,3),Nfft,fs,window,No);
p=sum(p')';
[f,c]=cumrms(f,p,fc,[],'sections');