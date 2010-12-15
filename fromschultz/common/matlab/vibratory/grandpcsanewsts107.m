function grandpcsanew(strLabel,strSensor,strFirstDay,strLastDay,blnOverlay,varargin);

% grandpcsanew(strLabel,strSensor,strFirstDay,strLastDay,blnOverlay,strSkipDay1,strSkipDay2,...);
%or
% grandpcsanew(strLabel,strSensor,strFirstDay,strLastDay,blnOverlay);
%
% grandpcsanew('gsummary','121f03','02-Jan-2002','15-Feb-2002',1,{'04-Jan_2002','09-Jan-2002','11-Feb-2002'});
%
% List of pcsa directories
% For each pcsa directory:
% 1. load hist2d file for freq & PSD bins
% 2. load ../<specInfo> file to get dT
% 3. add to H (and T for future work)
% 4. add to numPSDs
% After all H's & numPSD's added, imagesc
% Ancillary text with non-contiguous considered (dT*numPSDs)

% Inputs: strSensor - string for sensor id
%         strLabel - string for label (like gsummary or roadmaps)
%         strFirstDay - string to use with datenum to get first day
%         strLastDay - string to use with datenum to get last day
%         blnOverlay - boolean for overlay of OTO PSD curve
%         casSkipDays - cell array of strings for GMT days to exclude

% Loop for pcsa directories
strBase='t:\offline\batch\results\';
strBasepath=[strBase strSensor];
[casInfoFile,details]=dirdeal(sprintf('%s\\%s*spgs*%s*info.mat',strBasepath,strSensor,strLabel));
if length(casInfoFile)~=1
   error('need exactly 1 info mat-file')
else
   % Load spectrogram info file (for temporal resolution)
   load([details.pathstr casInfoFile{1}])
   % Compute temporal resolution
   dT=(sPlot.Nfft-sPlot.No)/sHeader.SampleRate;
end
sdnFirst=datenum(strFirstDay);
sdnLast=datenum(strLastDay);
strSkipDays='';
if nargin>5
   [casSkipDays]=deal(varargin);
	for iSkip=1:length(casSkipDays)
      sdnSkipDays(iSkip)=datenum(casSkipDays{iSkip});
      strSkipDays=[strSkipDays ', ' casSkipDays{iSkip}];
   end
   strSkipDays=['SKIP' strSkipDays(2:end)];
else
   sdnSkipDays=[];
end

blnDoneOne=0;
sdnAll=sdnFirst:sdnLast;
sdnKeep=setdiff(sdnAll,sdnSkipDays);
for sdn=sdnKeep
   %T:\offline\batch\results\year2002\month05\day25\121f02\padspec\roadmaps_pcsa\*.mat
   strWild=sprintf('%s\\year%4d\\month%02d\\day%02d\\%s\\padspec\\%s_pcsa\\*.mat',strBase,year(sdn),month(sdn),day(sdn),strSensor,strLabel);
   [casFiles,details]=dirdeal(strWild);
   if ~isempty(casFiles)
      % For each pcsa file, add histogram and count info (and later T) to grand totals
      strFile=casFiles{1};
      % Load file
      fprintf('\n%s',strFile)
      load([details.pathstr strFile])
      % Verify matching parameters
      if ~blnDoneOne
         % Initial values
         bigH=H;
         %bigT=T;
         totalPSDs=NUMPSDS;
         fBins=freqBins;
         pBins=PSDBins;
         blnDoneOne=1;
      else
         % Add to grand totals for H, numPSDs, and  (and T for future work)
         bigH=bigH+H;
         totalPSDs=totalPSDs+NUMPSDS;
         %bigT=[bigT T];
         if ( all(freqBins~=fBins) | all(PSDBins~=pBins) )
            error('mismatched bins')
         end
      end
   end
end

% Gather text
CLim=[0 1.5];
sText.strXType='Frequency';
sText.strXUnits='Hz';
sText.casYStub={''};
sText.casYTypes='YType';
sText.casYUnits='YUnits';
amountHours=(dT*totalPSDs)/3600;

% After all H's & numPSD's added, imagesc
%imagesc(freqBins,PSDBins,100*(bigH/totalPSDs)),axis xy,colormap(pimsmap2),colorbar
hs=plotpcsa(freqBins,PSDBins,bigH,totalPSDs,sText,'screen',CLim);
set(hs.TextUpperRight4,'str',sprintf('Total of %.1f hours',amountHours));
set(hs.TextUpperRight3,'str',sprintf('%s, %d PSDs',sPlot.Window,totalPSDs));
%set(hs.TextTitle,'str',sprintf('First Start GMT %s',popdatestr(sdnFirstStart,0)));
strComment=get(hs.TextComment,'str');
set(hs.TextComment,'str',{strComment,['GMT ' strFirstDay ' through ' strLastDay],strSkipDays});
set(hs.TextTitle,'str','');
set(gca,'ylim',[-14 -3]);

% If desired, add OTO PSD overlay curve
if blnOverlay
   strColor='Magenta';
   hold on
   load psd_from_oto
   hp=plot(FF,PP,strColor(1));
   xt=get(gca,'xtick');
   xpos=xt(3);
   yt=get(gca,'ytick');
   ypos=mean(yt(end-1:end));
   htxt=text(xpos,ypos,[strColor ' Overlay = "Vehicle+Payloads" Vibratory Requirements']);
   set(htxt,'color',strColor(1));
end

fprintf('\nwant to call retrosavepcsa for this gcf?\n')

fprintf('\ncaxis([0 2]);colorbar % use these 2 commands to change caxis\n')

str=popdatestr(sdnFirst,-2);str=str(1:end-13);
str1=strrep(str,':','_');
str=popdatestr(sdnLast,-2);str=str(1:end-13);
str2=strrep(str,':','_');

fprintf('\nFILENAME: %sthru%s_%s_pcsa_%dh_%g\n',str1,str2,strSensor,round(amountHours),sHeader.CutoffFreq)

set(hs.Axes11,'xtick',0:26);
cas=get(hs.TextComment,'str');
set(hs.TextComment,'str',cas{2});

set(hs.TextUpperLeft2,'str','100.0 sa/sec (26.3 Hz)')
set(hs.TextUpperRight1,'str','STS-107')
