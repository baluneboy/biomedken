function otoquartile(strSensorID,Y1,M1,D1,h1,m1,s1,Y2,M2,D2,h2,m2,s2,strTag,strLabel);

%ex.//
%otoquartile('121f03',2002,5,23,'otomaps','sleep',[0 0 0],[3 0 0]);
%otoquartile('121f03',2002,7,26,20,0,0,2002,7,26,23,0,0,'otomaps','label');
%         strSensorID,   S T A R T    ,    S T O P    ,strTag   ,strLabel

% Path for results depends on host
strPrePath=getpath4host('offline/batch/results/');

sdnStartOTO=datenum(Y1,M1,D1,h1,m1,s1);
sdnStopOTO=datenum(Y2,M2,D2,h2,m2,s2);

casFILES={};
sdnFileBegins=[];
for iDay=floor(sdnStartOTO):floor(sdnStopOTO)
   
   [strPathName,strInfoFilename]=date2paths(strPrePath,strSensorID,strTag,iDay);
   fprintf('\nPATH: %s',strPathName)
   
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
   
end

% Since above grabbed all files in day directories, weed to just desired start-to-stop files
iKeepFiles=find(sdnFileBegins>sdnStartOTO & sdnFileBegins<sdnStopOTO);
casFiles=casFILES(iKeepFiles);
sdnFileBegins=sdnFileBegins(iKeepFiles);

% Determine max freq for b rows to keep
fc=sHeader.CutoffFreq;
iKeepFreq=find(f<=fc);

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
sText.strTitle=['Time Frame: ' popdatestr(sdnStartOTO,0) ' to ' popdatestr(sdnStopOTO,0)];
sText.strComment=strLabel;

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

fprintf('\n\n')