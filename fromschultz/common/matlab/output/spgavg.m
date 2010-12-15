function spgavg(strSensorID,Y1,M1,D1,h1,m1,s1,Y2,M2,D2,h2,m2,s2,strTag,strLabel);

%ex.//
%spgavg('121f03',2002,5,23,'otomaps','sleep',[0 0 0],[3 0 0]);
%spgavg('121f03',2002,7,26,20,0,0,2002,7,26,23,0,0,'otomaps','label');
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
   
   %% Need to improve this specbat special chrono order files, but for now ...
   [CAS,sdnFileBegin]=specbatorderday(casFiles);
   casFILES=cappend(casFILES,CAS);
   sdnFileBegins=[sdnFileBegins(:); sdnFileBegin(:)];
   
end

% Since above grabbed all files in day directories, weed to just desired start-to-stop files
iKeepFiles=find(sdnFileBegins>sdnStartOTO & sdnFileBegins<sdnStopOTO);
casFiles=casFILES(iKeepFiles);
numFilesTotal=length(casFiles);
fprintf('now have %d files.',numFilesTotal)
sdnFileBegins=sdnFileBegins(iKeepFiles);

% Determine max freq for b rows to keep
fc=sHeader.CutoffFreq;
iKeepFreq=find(f<=fc);

% Initialize sums with first file's worth
[bsum,k]=locSum(casFiles{1},iKeepFreq);
Bsum=bsum;
K=k;
% Loop to concat b matrix
for iFile=2:numFilesTotal
   strFilename=casFiles{iFile};
   [bsum,k]=locSum(strFilename,iKeepFreq);
   Bsum=Bsum+bsum;
   K=K+k;
   fprintf('\nfile #%3d of %3d, K=%9d <= %s',iFile,numFilesTotal,K,strFilename)
end
Bavg=Bsum/K;

% Define plot text objects
sText.strXType='Frequency';
sText.strXUnits='Hz';
sText.casYStub={''};
sText.casYTypes={'PSD'};
sText.casYUnits={'g^2/Hz'};
sText.casRS={};
sText.strTitle=['Time Frame: ' popdatestr(sdnStartOTO,0) ' to ' popdatestr(sdnStopOTO,0)];
sText.strComment=strLabel;

% Plot data with generic 2D plot routine
sHandles=plotgen2d(f(iKeepFreq),Bavg,sText,sOutput.Type,[]);

% Adjust text and parameters
set(sHandles.Axes11,'yscale','log','ylimmode','auto');
strOldK=char(get(sHandles.TextUpperRight3,'str'));
iEq=findstr(strOldK,'=');
strNewK=sprintf('%s %d',strOldK(1:iEq),K);
set(sHandles.TextUpperRight3,'str',strNewK);
strOld=char(get(sHandles.TextUpperRight4,'str'));
set(sHandles.TextUpperRight4,'str',sprintf('%.2f hours',(sdnStopOTO-sdnStartOTO)*24));

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bsum,k]=locSum(strFilename,iKeepFreq);
load(strFilename) % load this file's spectrogram matrix
if hasstr('spg3',strFilename)
   clear b
   b(:,:,1)=bx;
   b(:,:,2)=by;
   b(:,:,3)=bz;
   clear bx by bz
end
k=nCols(b);
bsum=sum(b(iKeepFreq,:,:),2);