function oddotoquartile(strSensorID,Y,M,D,varargin);

%oddotoquartile - compute OTO quartile statistics for each input hour range
%
%Inputs: strSensorID - string for sensor
%        Y,M,D - integer year, month, day
%
%Output: implicit plot (eps) file
%        
%oddotoquartile(strSensorId,Y,M,D,[hourRange[s]]);
%oddotoquartile('121f03',2003,1,1); %same as oddotoquartile('121f03',2003,1,1,[0 8],[8 16],[16 24]);
%oddotoquartile('121f03',2003,1,1,[0 6],[6 15],[15 24]);

% Author: Ken Hrovat
% $Id: oddotoquartile.m 4160 2009-12-11 19:10:14Z khrovat $

strTag='oto'; % batch results subdir
sdnYMD=datenum(Y,M,D);
strLabel=datestr(sdnYMD);

if nargin==4
   hourRanges={[0 8],[8 16],[16 24]};
else
   [hourRanges{1:length(varargin)}]=deal(varargin{:});
end

% Path for results depends on host
strPrePath=getpath4host('offline/batch/results/');
[strPathName,strInfoFilename]=date2paths(strPrePath,strSensorID,strTag,sdnYMD);
fprintf('\nPATH: %s',strPathName)

casFILES={};
sdnFileBegins=[];

% Load info mat-file
load(strInfoFilename);
strBasepath=sOutput.ResultsPath;
strComment=sText.strComment;

% Check for good frequency resolution
df=f(2)-f(1);
if df>0.01
   error(sprintf('\nAborted because frequency resolution is %.3f Hz, while at most it should be is 0.01 Hz.',df))
end

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

%% Need to improve this specbat special chrono order files, but for now ...
[CAS,sdnFileBegin]=specbatorderday(casFiles);
casFILES=cappend(casFILES,CAS);
sdnFileBegins=[sdnFileBegins(:); sdnFileBegin(:)];

% Determine max freq for b rows to keep
fc=sHeader.CutoffFreq;
iKeepFreq=find(f<=fc);

for iRange=1:length(hourRanges)
   
   hrs=hourRanges{iRange};
   sdnStartOTO=datenum(Y,M,D,hrs(1),0,0);
   sdnStopOTO=datenum(Y,M,D,hrs(2),0,0);
   
   % Since above grabbed all files in day directory, weed to just desired start-to-stop files
   iKeepFiles=find(sdnFileBegins>sdnStartOTO & sdnFileBegins<sdnStopOTO);
   casFiles=casFILES(iKeepFiles);
   
   % Loop to concat b matrix
   B=[];
   for iFile=1:length(casFiles)
      strFilename=casFiles{iFile};
      % Load this file's spectrogram matrix
      load(strFilename)
      if hasstr('spg3',strFilename)
         clear b
         b(:,:,1)=bx;
         b(:,:,2)=by;
         b(:,:,3)=bz;
         clear bx by bz
      end
      B=[B b(iKeepFreq,:,:)];
      fprintf('\n#Bcols = %3d <= %s',nCols(B),strFilename)
   end
   
   % Calculate otogram (grms) matrix from spectrogram matrix
   [fcent,grms,franges,giss]=otofrompsd(f(iKeepFreq),B,fc);
   clear B
   
   % Get number of samples
   numSamples=max(sum(not(isnan(grms'))));
   
   % Define plot text objects
   sText.strXType='Frequency';
   sText.strXUnits='Hz';
   sText.casYStub={'RMS'};
   sText.casYTypes={'Acceleration'};
   sText.casYUnits={'g_{RMS}'};
   sText.casRS={};
   strFromTo=sprintf('from %s to %s',locHHMMstr(sdnStartOTO),locHHMMstr(sdnStopOTO));
   sText.strTitle={['GMT ' strLabel],strFromTo};
   sText.strComment='';
   
   % Plot data with generic 2D plot routine
   sHandles=plotgen2d([1;2],[1;2],sText,sOutput.Type,[]);
   
   % Add ISS requirements curve
   sHandles=issoverlay(sHandles,'r','solid',1.5);
   
   set(sHandles.Axes11,'xscale','log','yscale','log');
   delete(sHandles.Line11)
   
   % Build OTO percentile matrix
   otop=nan*ones(46,5); % hold the "5" quartiles
   for i=1:nRows(grms)
      m=excisenan(grms(i,:));
      if ~isempty(m)
         otop(i,:)=percentile(m,[0 25 50 75 100]);
      end
   end
   
   % Get requirements data
   moto=otoissreq;
   fcent=moto(:,2);
   clear moto
   
   % Only shows stats in bands that have values
   iGoodBands=find(~isnan(otop(:,1))); % check down column 1 for ~NaNs
   axes(sHandles.Axes11)
   hold on
   for iNum=1:length(iGoodBands)
      i=iGoodBands(iNum);
      h=plot(fcent(i),otop(i,1),'kv',fcent(i),otop(i,3),'ko',fcent(i),otop(i,5),'k^');
      hline=line(fcent(i)*[1 1],[otop(i,2) otop(i,4)]);
      set(hline,'color','k');
   end
   hold off
   
   strOldK=char(get(sHandles.TextUpperRight3,'str'));
   iEq=findstr(strOldK,'=');
   strNewK=sprintf('%s %d',strOldK(1:iEq),numSamples);
   strOld=char(get(sHandles.TextUpperRight4,'str'));
   set(sHandles.TextUpperRight4,'str','');
   set(sHandles.TextUpperRight3,'str',strNewK);
   
   set(sHandles.Axes11,'xlim',[1e-2 300],'ylim',[1e-8 1e-2])
   
   strNumHours=sprintf('%dh',round((sdnStopOTO-sdnStartOTO)*24));
   locPrintEPSclose(gcf,sdnYMD,sdnStartOTO,strTag,sHeader,sPlot,strNumHours);
   
end

fprintf('\n\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strHHMM=locHHMMstr(sdn);
str=datestr(sdn,13);
strHHMM=str(1:5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locPrintEPSclose(hFig,sdnYMD,sdnTitleStart,strTag,sHeader,sPlot,strNumHours); 
strCutoff=strrep(sprintf('%g',sHeader.CutoffFreq),'.','p');
strImageFilename=locGenimgfilename(sdnTitleStart,[strNumHours '_' strCutoff 'hz'],sHeader.SensorID,'oto',sPlot.WhichAx);
strPath=[getpath4host('www/plots/batch/',sdnYMD) 'eps' filesep];
if ~exist(strPath)
   [statusVal,strMsg]=pimsmkdir(strPath);
   if ~isempty(strMsg)
      fprintf('\npimsmkdir message for %s: %s\n',strPath,strMsg)
   end      
end
set(gcf,...
   'PaperPositionMode' , 'manual',...
   'PaperUnits','inches',...
   'PaperOrientation' , 'landscape',...
   'PaperPosition' , [0.32684 0.25 10.3463 8],...
   'PaperType' , 'usletter');
print('-depsc','-tiff','-r600',[strPath strImageFilename])
fprintf('\nDone printed %s',[strPath strImageFilename])
close(hFig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strImageFilename=locGenimgfilename(sdnTitleStart,strComment,strID,strType,strWhichAx);
strExt='eps';
strStartTime=strrep(popdatestr(sdnTitleStart,-2),':','_');
iDot=findstr(strStartTime,'.');
strStartTime=strStartTime(1:iDot-1);
%strComment=locRemoveUnd(strComment);
strComment=strrep(strComment,' ','');
strID=locRemoveUnd(strID);
strID=strrep(strID,'hirap','mhirap');
strType=locRemoveUnd(strType);
strWhichAx=locRemoveUnd(strWhichAx);
strExt=locRemoveUnd(strExt);

% Abbreviate WhichAx from structure of plot parameters
switch strWhichAx
case {'x','y','z'}
   % single char ok
case 'sum'
   strWhichAx='s';
case 'vecmag'
   strWhichAx='m';
case 'xyz'
   strWhichAx='3';
otherwise
   error('unknown axis string')
end

u='_';
strImageFilename=[strStartTime u strID u strType strWhichAx u strComment '.' strExt];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=locRemoveUnd(strU);
str=strrep(strU,'_','');