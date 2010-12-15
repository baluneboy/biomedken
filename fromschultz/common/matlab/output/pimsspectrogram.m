function sHandles=pimsspectrogram(varargin);

%pimsspectrogram
%
%sHandles=pimsspectrogram(hDisposalFig,sDisposition); % gui syntax
%or
%sHandles=pimsspectrogram(data,sHeader,sParameters,strComment); % command line
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

%Author: Ken Hrovat

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

% Convert acceleration units (if needed)
[data(:,2:end),sHeader,tScaleFactor,strNewTUnits,gScaleFactor]=convertunits(data(:,2:end),sHeader,sPlot);

% Gather parameters for pimsspecgram
fs=sHeader.SampleRate;
fc=sHeader.CutoffFreq;
Nfft=sPlot.Nfft;
Nwin=Nfft;
No=sPlot.No;
FLim=sPlot.FLim;
strCLimMode=sPlot.CLimMode;
CLim=sPlot.CLim;
strColormap=sPlot.Colormap;

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
sText.strXType='Time';
switch strWhichAx
case 'xyz'
   sText.casYStub={'X-Axis';'Y-Axis';'Z-Axis'}; % YLabel stubs
   [data,dataMean,dataRMS]=locDemeanAndStats(data);
   [b(:,:,1),f,t]=pimsspecgram(data(:,1),Nfft,fs,window,No);   
   [b(:,:,2),f,t]=pimsspecgram(data(:,2),Nfft,fs,window,No);   
   [b(:,:,3),f,t]=pimsspecgram(data(:,3),Nfft,fs,window,No);
case 'sum'
   sText.casYStub={'\Sigma'};
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
clear data; % b is now data matrix of interest

% Determine the clim to use (for auto)
if strcmp(strCLimMode,'auto')
   ind=find(f<=FLim(2));
   bmin=min(min(b(ind,:,:)));
   bmax=max(max(b(ind,:,:)));
   CLim=log10([bmin bmax]);
end

% Gather text
sz=size(b);
numPSDs=sz(2);
TUnits=sPlot.TUnits;
sText.strXUnits=TUnits;
sText.strComment=strComment;
% moved casUL up before transformation from here
secSpan=t(end)-t(1);
strSpan=sprintf('Span = %.2f %s',double(convert(secSpan*units('seconds'),TUnits)),TUnits);
sText.casUR=locGetTextUR(sHeader,sPlot,numPSDs,strSpan);
strTimeFormat=sSearch.PathQualifiers.strTimeFormat;
sText.strTitle=starttimetitle(sHeader.sdnDataStart,sSearch.PathQualifiers.strTimeBase,strTimeFormat);
sText.strVersion=bottomdateline(sSearch.PathQualifiers.strBasePath);

% Branch on output type
strOutputType=lower(sOutput.Type);
switch strOutputType
case 'datafilebat'
   
   sHandles=[]; % no handles to return
   
   % Path for results
   %strResultsPath=sDisposition.ResultsPath;
   %strUnique=sDisposition.UniqueString;
   strResultsPath=sOutput.ResultsPath;
   strUnique=sOutput.StringID;
   strTrunk=[strResultsPath strUnique '_'];
   
   % Save info file (if first in batch)
   strInfoFilename=[strTrunk 'info.mat'];
   if ~exist(strInfoFilename)
      if ~exist(strResultsPath)
         [statusVal,strMsg]=pimsmkdir(strResultsPath);
         if ~isempty(strMsg)
            fprintf('\npimsmkdir message for %s: %s\n',strResultsPath,strMsg)
         end         
      end
      uSpanSec=secSpan*units('seconds');
      numCat=round(double(sPlot.TSpan*units(sPlot.TUnits)/uSpanSec));
      save(strInfoFilename,'f','sText','sHeader','sSearch','sPlot','sOutput','strTrunk','numCat');
      % Initialize running color limit histogram (if first in batch)
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
      iKeepFreq=find(f<=sPlot.FLim(2)); % determine max freq for b rows to consider for hist
      strHistname=[strTrunk 'hist.mat'];
      load(strHistname)
      histNewN=histc(log10(b(iKeepFreq,:)),histEdges);%histNewN=histc(log10(b(:)),histEdges);
      histN=histN+sum(histNewN,2)';%histN=histN+histNewN(:)';
      count=count+1;
      save(strHistname,'histN','histEdges','count');
   end
   
case 'imagefilebat'
   
   % Tweak for daily script (stop is start plus a day)
   sSearch.PathQualifiers.sdnStop=sSearch.PathQualifiers.sdnStart+1;
   
   % Save info file (when config file is first generated)
   u=filesep;
   %strYM=sprintf('%d_%02d',year(sHeader.sdnDataStart),month(sHeader.sdnDataStart));
   padspecPath=[sOutput.ResultsPath sHeader.SensorID u];
   strInfoFilename=[padspecPath '_infotemp.mat']
   if exist(strInfoFilename)
      error(sprintf('--- %s already exists, so not overwritten',strInfoFilename))
   end
   save(strInfoFilename,'f','sText','sHeader','sSearch','sPlot','sOutput');
   
otherwise
   
   % Put time in desired units
   t=t*tScaleFactor;
   
   % Prompt for CLim (if needed)
   if strcmp(strCLimMode,'hist')
      CLim=selectcolorlim(b);
   end
   
   % Plot data with generic plot routine for spec
   sHandles=plotgenspec(t,f,b,sText,sOutput.Type,[],CLim);
   
   % Incorporate plot parameter settings
   colormap(sPlot.Colormap)
   
   %if strcmp(sPlot.TLimMode,'auto')
   %   set(sHandles.AxesALL,'xlimmode','auto');
   %else
   %   set(sHandles.AxesALL,'xlimmode','manual','xlim',sPlot.TLim);
   %end
   set(sHandles.AxesALL,'ylim',sPlot.FLim);
   set(gcf,'Name',figname('spg',strWhichAx));
   
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
   
   [hMenu,strFilename]=addprintmenu(gcf,secSpan);
   
   % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % % revise to something like: sHandles=locComputeSpecgramtrogrammenus(?); %
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
   % %   end of something like: sHandles=locComputeSpecgramtrogrammenus(?);  %
   % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data,dataMean,dataRMS]=locDemeanAndStats(data);

% Compute mean of data
dataMean=nanmean(data);

% Demean data
data=data-ones(nRows(data),1)*dataMean;

% Compute RMS of data
dataRMS=nanrms(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUL=locGetTextUL(sHeader,sPlot);
fs=sHeader.SampleRate;
Nfft=sPlot.Nfft;
No=sPlot.No;
casUL=top2textul(sHeader);
casUL{3}=sprintf('\\Deltaf = %.3f Hz,  Nfft = %d',fs/Nfft,Nfft);
casUL{4}=sprintf('Temp. Res. = %.3f sec, No = %d',(Nfft-No)/fs,No);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function casUR=locGetTextUR(sHeader,sPlot,numPSDs,strSpan);
casUR=top2textur(sHeader);
if strcmp(sPlot.WhichAx,'sum')
   casUR{2} = 'Sum';
end

strWindow=[upper(sPlot.Window(1)) sPlot.Window(2:end)];
casUR{3}=sprintf('%s, k = %g',strWindow,numPSDs);
casUR{4}=strSpan; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [b,f,t]=locComputeSpecgram(x,nfft,fs,window,noverlap);
[b,f,t]=pimsspecgram(x,nfft,fs,window,noverlap);