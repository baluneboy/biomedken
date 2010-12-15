function specialspecbat(varargin);

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
   strPathName='e:\TEMP\RESULTS\INC02\HIRAP\spectrogram\MAMSHiRAP_tp425643\';
   %strPathName='S:\TEMP\RESULTS\INC02\HIRAP\spectrogram\MAMSHiRAP_tp425643\';
   %strPathName='T:\offline\popbetamatlab\results\inc02\hirap\spectrogram\MAMSHiRAP_tp425643\';
   %strPathName='/r/sdds/pims/offline/popbetamatlab/results/inc02/hirap/spectrogram/MAMSHiRAP_tp425643/';
   strInfoFilename=[strPathName 'MAMSHiRAP_tp425643_info.mat'];
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

% May need this eventually
while 0
   dT=(sPlot.Nfft-sPlot.No)/sHeader.SampleRate;
   tRelSec=86400*(t-t(1));
   numColsShouldBe=(tRelSec(end)/dT)+1;
   numdt=round(max(t)/dT);st=snap2grid(t,0,dT,numdt*dT);
end

%% Need to improve this specbat special chrono order files, but for now ...
[casFiles,sdnFileBegins]=specbatorder(casFiles);

% Loop via time per plot after initialize for first plot
blnGotPlotPilot=0;
iPlot=1;
sdnPlotBegin=sdnStart;
%sdnPlotEnd=sdnPlotBegin+daysPerPlot;
sdnPlotEnd=sdnStop;
while sdnPlotEnd<=(sdnStop+sdnFudge)
   index=find(sdnFileBegins>=(sdnPlotBegin-sdnFudge) & sdnFileBegins<(sdnPlotEnd-sdnFudge));
   fprintf('\nPlot #%3d FROM %s TO %s ',iPlot,datestr(sdnPlotBegin,0),datestr(sdnPlotEnd,0))
   if isempty(index)
      fprintf('-- no files found, so skip this plot.')
   else
      
      % Loop through files for ith plot
      casPlotFiles=casFiles(index); % here are files needed to loop load (just times for now)
      fprintf('%3d files FROM %4d TO %4d of %g total.',length(index),index(1),index(end),numFilesTotal)
      
      % Coerce concatenated times to suitable plot grid times and incorporate first file's contribution
      strFirstFile=casPlotFiles{1};
      [B,indBmap,sdnPlotTimes,gridMin,gridMax,sdnPreviousEnd,numAx]=binitialize(sdnPlotBegin,sdnPlotEnd,gridStep,strFirstFile,iKeepFreq);
      [strPathPart,strNamePart,strExt,strVer]=fileparts(strFirstFile);
      fprintf('\n%3d (Bcols %4d to %4d): %s',index(1),indBmap(1),indBmap(end),strNamePart)
      casPlotFiles(1)=[];
      index(1)=[];
      
      for iFile=1:length(index)
         
         strFilename=casPlotFiles{iFile};
         
         % Load this file's b matrix and t vector
         load(strFilename)
         
         % Snap time to grid
         [sdnSnapped,indBmap]=batsnaptime(t,sdnPlotTimes,gridMin,gridMax,gridStep);
         
         % Verify t(1)>=(sdnPreviousEnd+gridStep)
         if t(1)<(sdnPreviousEnd+gridStep)
            warning('first time in file for this plot is less than previous end plus a time step')
         end
         
         % Get last time of this file's contribution
         sdnPreviousEnd=sdnSnapped(end);         
         
         % Incorporate contribution to B
         for iAx=1:numAx
            B(:,indBmap,iAx)=b(iKeepFreq,:,iAx);
         end
         [strPathPart,strNamePart,strExt,strVer]=fileparts(strFilename);
         fprintf('\n%3d (Bcols %4d to %4d): %s',index(iFile),indBmap(1),indBmap(end),strNamePart)
         
      end
      
      % Make time relative seconds
      t=sdnPlotTimes-sdnPlotTimes(1); % days
      t=double(convert(t*units('days'),sPlot.TUnits));
      strSpan=sprintf('Span = %.2f %s',t(end),sPlot.TUnits);
      
      clear T
      
      % Spectrogram-specific text
      numPSDs=sum(~isnan(B(1,:)));
      strWindow=[upper(sPlot.Window(1)) sPlot.Window(2:end)];
      sText.casUR{3}={sprintf('%s, k = %g',strWindow,numPSDs)};
      sText.casUR{4}={strSpan};
      
      % If not super batch, then get color limits
      if ~blnSuper
         % On first plot, get color limits (if histogram file exists)
         if ~blnGotPlotPilot
            if ~exist(strHistFilename)
               CLim=[-12 -6];
            else
               % Choose color limit
               CLim=selectcolorlim(strHistFilename);
            end
         end
      end
      
      % Plot this image
      %sText.strTitle=['Start ' strTimeBase ' ' popdatestr(sdnPlotTimes(1),strTimeFormat)];
		sText.strTitle=starttimetitle(sdnPlotBegin,sSearch.PathQualifiers.strTimeBase,strTimeFormat);
      sHandles=plotgenspec(t,f(iKeepFreq),B,sText,sOutput.Type,[],CLim);
		% TWEAKS for startime and name and menu near here      
      set(gcf,'Name','spg3');
      [hMenu,strFilename]=addprintmenu(gcf);
      
      disp('return before settings and eps code')
      
      return
      
      
      % If not super batch, then get time limits and ticks
      if ~blnSuper
         % Set axes properties
         if ~blnGotPlotPilot
            % Choose time limit and ticks for all plots in batch
            oldTLim=get(gca,'xlim');
            oldTTicks=get(gca,'xtick');
            [TLim,tTicks]=limtickdlg(oldTLim,oldTTicks);
            blnGotPlotPilot=1;
         end
      end
      colormap(sPlot.Colormap);
      set(sHandles.AxesALL,'ylim',sPlot.FLim);
      set(sHandles.AxesALL,'ytick',0:1:15);   %SPECIALIZED
      set(sHandles.AxesALL,'xlim',TLim);
      set(sHandles.AxesALL,'xtick',tTicks);
      
      % Image times
      switch sPlot.TTickLabelMode
      case 'relative'
         % as-is should work?
         sdnTitleStart=sdnPlotTimes(1);
      case 'dateaxis'
         sHeader.sdnDataStart=sdnPlotBegin;
         batdateaxis(t,sHandles,sHeader,sPlot);
         xlim=get(gca,'xlim');
         sdnTitleStart=xlim(1);
         sdnTitleStart=locNudgeTime(sdnTitleStart); % MATLAB problem
         strTitle=['Start ' strTimeBase ' ' popdatestr(sdnTitleStart,strTimeFormat)];
         iDot=findstr(strTitle,'.');
         strTitle=strTitle(1:iDot-1);
         set(sHandles.TextTitle,'str',strTitle);
      otherwise
         error('unknown TTickLabelMode')
      end
      
      if 0
         % Print Encapsulated PostScript file
         strExt='eps';
         strSubDir=[strExt filesep];
         strImageFilename=genimgfilename(sdnTitleStart,strComment,sHeader.SensorID,'spg',sPlot.WhichAx,iPlot,strExt);
         strPath=[strPathName strSubDir];
         if ~exist(strPath)
            [statusVal,strMsg]=pimsmkdir(strPath);
            if ~isempty(strMsg)
               fprintf('\npimsmkdir message for %s: %s\n',strPath,strMsg)
            end      
         end
         set(gcf,...
            'PaperPositionMode' , 'manual',...
            'PaperUnits','inches',...
            'PaperOrientation' , 'portrait',...
            'PaperPosition' , [0.25 2.40711 8 6.18577],...
            'PaperType' , 'usletter');
         print('-depsc','-tiff','-r600',[strPath strImageFilename])
      end
      
      if iPlot>4
         close(gcf);
      end
      
   end
   
   clear B sdnPlotTimes
   iPlot=iPlot+1;
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