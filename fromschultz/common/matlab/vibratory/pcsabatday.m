function pcsabatday(varargin);

%ex.//
%pcsabatday('121f03',2002,5,23,'tvis');
%5 input args:
%strSensorID
%numYear
%numMonth
%numDay
%strTag

% Set flag for super batch
blnSuper=0;

% Get results path
s=get(0,'UserData');
if isfield(s,'sUser')
   s=s.sUser;
   strResultsPath=s.ResultsPath;
else
   fprintf('\nno sUser in root''s UserData, so start at pwd')
   strResultsPath=pwd;
end

% Special code for quick load
if nargin==0
   % Dialog for info filename to work from
   [strInfoFilename,strPathName]=uigetfile([strResultsPath '*info.mat'], 'specbat');
   strInfoFilename=[strPathName strInfoFilename];
elseif nargin==1
   strSensor='121f03';
   strYYYY='2002';
   strMM='05';
   strDD='23';
   strTag='tvis';
   u=filesep;
   strPathName=['T:\offline\batch\results\' strSensorID u strYYYY '_' strMM u 'day' strDD '\padspec\' strTag u];
   isep=findstr(strPathName,filesep);
   strYM=strPathName(isep(end-4)+1:isep(end-3)-1);
   strDay=strPathName(isep(end-3)+4:isep(end-2)-1);
   strInfoPath=strPathName(1:isep(end-4));
   sDir=dir([strInfoPath '*info.mat']);
   if length(sDir)~=1
      error('num of info mat files must be exactly 1')
   end
   strInfoFilename=[strInfoPath sDir.name];
elseif nargin==5
   [strSensorID,numYear,numMonth,numDay,strTag]=deal(varargin{:});
   yyyy=num2str(numYear);
   mm=sprintf('%02d',numMonth);
   dd=sprintf('day%02d',numDay);
   u=filesep;
   [strHost,strRemote]=pophostname;
   switch strHost
   case 'pcwin'
      strPrePath='T:\offline\batch\results\';
   case 'ra'
      strPrePath='/sdds/pims2/offline/batch/results/';
   otherwise
      error(sprintf('unknown host %s',strHost))
   end %switch strHost
   strPathName=[strPrePath 'year' yyyy u 'month' mm u dd u strSensorID u 'padspec' u strTag u]; % NEW
   isep=findstr(strPathName,filesep);
   strYM=[strPathName(isep(end-6)+5:isep(end-6)+8) '_' strPathName(isep(end-5)+6:isep(end-5)+7)]; % NEW
   strDay=strPathName(isep(end-4)+4:isep(end-3)-1); % NEW
   strInfoPath=strPathName(1:isep(end-4));
   strInfoFilename=getinfofile(strInfoPath,strSensorID,strTag); % NEW
elseif nargin==7
   [trash,strHostname]=unix('hostname');
   iTen=find(abs(strHostname)==10);
   if ~isempty(iTen),strHostname(iTen)=[];end
   switch strHostname
   case {'behemoth','elisabeth'}
      strPIMSpath='/r/tsccrusader/sdds/';
   case 'ra'
      strPIMSpath='/r/sdds/pims/';
   otherwise
      error('unknown host for pathing')
   end % switch strHostname
   blnSuper=1;
   [strSubDir,strSensorID,sdnStart,sdnStop,CLim,TLim,tTicks]=deal(varargin{:});
   strSubDir=deblankboth(strSubDir);
   strPathName=[strPIMSpath 'offline/batch/results/inc03/' strSensorID filesep 'spectrogram' filesep strSubDir filesep];
   strInfoFilename=[strPathName strSubDir '_info.mat'];
else
   error('wrong nargin')
end

fprintf('\nPATH: %s',strPathName)

% Load info mat-file
load(strInfoFilename);
strBasepath=sOutput.ResultsPath;
strComment=sText.strComment;

% Get hist2d parameters
[FLim,CLim]=locGetHistParameters(sPlot);

if ~blnSuper
   % Adjust for overall plot [8-hour] start/stop
   sSearch=locStartStop(sSearch);
else
   sSearch.PathQualifiers.sdnStart=sdnStart;
   sSearch.PathQualifiers.sdnStop=sdnStop;
end

% Determine max freq for b rows to keep
df=f(2)-f(1);
iKeepFreq=find(f<=sPlot.FLim(2)+df);

% Loop for concatenate & plot
sdnFudge=86400e-8;
sdnStart=sSearch.PathQualifiers.sdnStart;
sdnStop=sSearch.PathQualifiers.sdnStop;
dT=(sPlot.Nfft-sPlot.No)/sHeader.SampleRate;
gridStep=dT/86400;
hoursPerPlot=double(convert(sPlot.TSpan*units(sPlot.TUnits),'hours'));
daysPerPlot=hoursPerPlot/24;
strTimeFormat=sSearch.PathQualifiers.strTimeFormat;
strTimeBase=sSearch.PathQualifiers.strTimeBase;
fprintf('\nPlots to span FROM %s TO %s with dT = %f sec. says PATH/<info file>',datestr(sdnStart,0),datestr(sdnStop,0),dT)

% Get list of filenames
fprintf('\nGetting list of filenames using dirdeal(PATH/*.mat) ... ')
[casFiles,sDetails]=dirdeal([strPathName '*.mat']);
if ~isempty(sDetails)
   strPath=sDetails(1).pathstr;
   casFiles=strcat(strPath,casFiles);
else
   error('details structure is empty?')
end
fprintf('found %d files.',length(casFiles))

% Weed out info and hist files
fprintf('\nWeeding list of filenames (exclude info & hist files) ... ')
ii=strmatch(strInfoFilename,casFiles);
if ~isempty(ii), casFiles(ii)=[]; sDetails(ii)=[]; end

strHistFilename=strrep(strInfoFilename,'info','hist');
ih=strmatch(strHistFilename,casFiles);
if ~isempty(ih), casFiles(ih)=[]; sDetails(ih)=[]; end
numFilesTotal=length(casFiles);
fprintf('now have %d files.',numFilesTotal)

%% Need to improve this special chrono order files, but for now ...
[casFiles,sdnFileBegins]=specbatorderday(casFiles);

% Loop via time per plot after initialize for first plot
blnGotPlotPilot=0;
iHist=1;
sdnPlotBegin=sdnStart;
sdnPlotEnd=sdnPlotBegin+daysPerPlot;
while sdnPlotEnd<=(sdnStop+sdnFudge)
   index=find(sdnFileBegins>=(sdnPlotBegin-sdnFudge) & sdnFileBegins<(sdnPlotEnd-sdnFudge));
   fprintf('\nHist #%3d FROM %s TO %s ',iHist,datestr(sdnPlotBegin,0),datestr(sdnPlotEnd,0))
   if isempty(index)
      fprintf('-- no files found, so skip this plot.')
   else
      
      % Loop through files for ith plot
      casPlotFiles=casFiles(index); % here are files needed to loop load (just times for now)
      fprintf('%3d files FROM %4d TO %4d of %g total.',length(index),index(1),index(end),numFilesTotal)
      
      % Incorporate first file's contribution
      strFirstFile=casPlotFiles{1};
      load(strFirstFile)
      T=t;
      [H,freqBins,PSDBins,numPSDs]=hist2dspec(f,b,FLim,CLim);
      [strPathPart,strNamePart,strExt,strVer]=fileparts(strFirstFile);
      fprintf('\n%3d (  initial   %4d PSDs): %s',index(1),numPSDs,strNamePart)
      casPlotFiles(1)=[];
      index(1)=[];
      
      % Values for save of intermediate 2D histogram
      strExt='pcsa';
      strSubDir=['pcsa' filesep];
      strHist2DFilename=genimgfilename(sdnPlotBegin,strComment,sHeader.SensorID,'pcsa',sPlot.WhichAx,iHist,'mat');
      strPath=[strPathName strSubDir];
      if ~exist(strPath)
         [statusVal,strMsg]=pimsmkdir(strPath);
         if ~isempty(strMsg)
            fprintf('\npimsmkdir message for %s: %s\n',strPath,strMsg)
         end      
      end
      [strPathPart,strNamePart,strExt,strVer]=fileparts(strPathName(1:end-1));
      save([strPath strNamePart '_hist2d'],'freqBins','PSDBins');%just for first file
      
      for iFile=1:length(index)
         
         strFilename=casPlotFiles{iFile};
         
         % Load this file's b matrix
         load(strFilename)
         [h,freqBins,PSDBins,num]=hist2dspec(f,b,FLim,CLim);
         
         % Incorporate contribution to H
         if ~isempty(h)
            H=H+h;
            numPSDs=numPSDs+num;
            T=[T t];
         end
         
         [strPathPart,strNamePart,strExt,strVer]=fileparts(strFilename);
         fprintf('\n%3d (+%4d gives %4d PSDs): %s',index(iFile),num,numPSDs,strNamePart)
         
      end
      
      % Save of intermediate 2D histogram
      if numPSDs>0
         save([strPath strHist2DFilename],'H','T','numPSDs')
      end
      
   end
   
   clear H T numPSDs
   iHist=iHist+1;
   sdnPlotBegin=sdnPlotEnd;
   sdnPlotEnd=sdnPlotBegin+daysPerPlot;
   
end
fprintf('\n\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sdnNudged=locNudgeTime(sdn);
% Like in popdatestr, don't ask why we need this (MATLAB bug)
sdnNudged=sdn;
secs=second(sdn);
iBad=find(secs>59.999);
secAdd=1e-4;
sdnNudged(iBad)=sdnNudged(iBad)+(secAdd/86400);
sdnNudged=sdnNudged+1e-8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sSearch=locStartStop(sSearch);
% Adjust for overall plot [8-hour] start/stop
prompt={'Enter start date string','Enter stop date string'};
def={datestr(sSearch.PathQualifiers.sdnStart),datestr(sSearch.PathQualifiers.sdnStop)};
dlgTitle='Input for Overall [8-Hour] Plot Start/Stop Times';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
sSearch.PathQualifiers.sdnStart=datenum(answer{1});
sSearch.PathQualifiers.sdnStop=datenum(answer{2});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FLim,CLim]=locGetHistParameters(sPlot);
prompt={'Enter [minFreq maxFreq]','Enter [minPSD maxPSD] (like [-14 -3])'};
def={sprintf('[%.1f %.1f]',sPlot.FLim(1),sPlot.FLim(2)),sprintf('[-14 -3]')};%sprintf('[%.1f %.1f]',sPlot.CLim(1),sPlot.CLim(2))};
dlgTitle='Input for 2D Histogram Limits';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);
FLim=eval(answer{1});
CLim=eval(answer{2});