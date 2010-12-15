function otomeansigma(strSensorID,Y1,M1,D1,h1,m1,s1,Y2,M2,D2,h2,m2,s2,strTag,strLabel);

%ex.//
%otomeansigma('121f03',2002,5,23,'otomaps','sleep',[0 0 0],[3 0 0]);
%otomeansigma('121f03',2002,7,26,20,0,0,2002,7,26,23,0,0,'otomaps','label');
%         strSensorID,   S T A R T    ,    S T O P    ,strTag   ,strLabel

[strHost,strRemote]=pophostname;
switch strHost
case 'pcwin'
   strPrePath='T:\offline\batch\results\';
case 'ra'
   strPrePath='/sdds/pims2/offline/batch/results/';
otherwise
   error(sprintf('unknown host %s',strHost))
end %switch strHost

sdnStartOTO=datenum(Y1,M1,D1,h1,m1,s1);
sdnStopOTO=datenum(Y2,M2,D2,h2,m2,s2);

casFILES={};
sdnFileBegins=[];
for iDay=floor(sdnStartOTO):floor(sdnStopOTO)
   
   [strPathName,strInfoFilename]=locDate2Paths(strPrePath,strSensorID,strTag,iDay);
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
      strWhichAx='xyz';
   else
      strWhichAx='sum';
   end
   B=[B b(iKeepFreq,:,:)];
   fprintf('\n#Bcols = %3d <= %s',nCols(B),strFilename)
end

% Calculate otogram (grms) matrix from spectrogram matrix
[fcent,grms,franges,giss]=otofrompsd(f(iKeepFreq),B,fc);
clear B

% Calculate statistics for plot
otomeans=nanmean(grms')';
otostds=nanstd(grms')';
numSamples=max(sum(not(isnan(grms'))));

% Build CSV filename
str1=genimgfilename(sdnStartOTO,'dummy','dummy','dummy',strWhichAx,0,'dummy');
str2=genimgfilename(sdnStopOTO,strLabel,strSensorID,'oms',strWhichAx,numSamples,'csv');
strImageFilename=[str1(1:20) str2];

% Write CSV file

fprintf('\n\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [strPathName,strInfoFilename]=locDate2Paths(strPrePath,strSensorID,strTag,sdn);

yyyy=num2str(year(sdn));
mm=sprintf('%02d',month(sdn));
dd=sprintf('day%02d',day(sdn));

u=filesep;
strPathName=[strPrePath 'year' yyyy u 'month' mm u dd u strSensorID u 'padspec' u strTag u]; % NEW
isep=findstr(strPathName,filesep);
strYM=[strPathName(isep(end-6)+5:isep(end-6)+8) '_' strPathName(isep(end-5)+6:isep(end-5)+7)]; % NEW
strDay=strPathName(isep(end-4)+4:isep(end-3)-1); % NEW
strInfoPath=strPathName(1:isep(end-4));
strInfoFilename=getinfofile(strInfoPath,strSensorID,strTag); % NEW