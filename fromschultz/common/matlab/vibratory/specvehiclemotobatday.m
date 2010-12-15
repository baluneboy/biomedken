function specvehiclemotobatday(varargin);

% specvehiclemotobatday(strSensorID,numYear,numMonth,numDay);
% specvehiclemotobatday('121f03',2002,10,14);

% Load info mat-file (this gives f & temporal resolution, dT)
% Get list of vehiclemoto files for the day specified
% For each file, do these:
%   load file
%   get start time from name of file
%   generate t row using start time & dT

% Initialize
strTag='vehiclemoto'; % all files should use this tag

% Get results path
s=get(0,'UserData');
if isfield(s,'sUser')
   s=s.sUser;
   strResultsPath=s.ResultsPath;
else
   fprintf('\nno sUser in root''s UserData, so start at pwd')
   strResultsPath=pwd;
end

strLocalOutpath=[];

if nargin==4
   [strSensorID,numYear,numMonth,numDay]=deal(varargin{:});
   yyyy=num2str(numYear);
   mm=sprintf('%02d',numMonth);
   dd=sprintf('day%02d',numDay);
   u=filesep;
   [strHost,strRemote]=pophostname;
   switch strHost
   case 'pcwin'
      strPrePath='T:\offline\batch\results\';
   case {'ra','ra-new'}
      strPrePath='/sdds/pims2/offline/batch/results/';
      if ~isdir(strPrePath)
         strLocalOutpath='/cvs/local/';
      end
   case 'elisabeth'
      strPrePath='/r/sdds/pims2/offline/batch/results/';
   case 'behemoth'
      strPrePath='/r/sdds/pims2/offline/batch/results/';
   otherwise
      error(sprintf('unknown host %s',strHost))
   end %switch strHost
   strPathName=[strPrePath 'year' yyyy u 'month' mm u dd u strSensorID u 'padspec' u strTag u]; % NEW
   isep=findstr(strPathName,filesep);
   strYM=[strPathName(isep(end-6)+5:isep(end-6)+8) '_' strPathName(isep(end-5)+6:isep(end-5)+7)]; % NEW
   strDay=strPathName(isep(end-4)+4:isep(end-3)-1); % NEW
   strInfoPath=strPathName(1:isep(end-4));
   strInfoFilename=getinfofile(strInfoPath,strSensorID,strTag); % NEW
else
   error('wrong fargin nargin')
end

fprintf('\nPATH: %s',strPathName)

% Load info mat-file
load(strInfoFilename);
dT=(sPlot.Nfft-sPlot.No)/sHeader.SampleRate;
strBasepath=sOutput.ResultsPath;
strComment=sText.strComment;

% Get list of filenames
fprintf('\nGetting list of filenames using dirdeal(PATH/*.mat) ... ')
[casFiles,sDetails]=dirdeal([strPathName '*.mat']);
if ~isempty(sDetails)
   strPath=sDetails(1).pathstr;
   casFiles=strcat(strPath,casFiles);
   strPathPCSA=strrep(strPath,[filesep strTag filesep],[filesep strTag '_pcsa' filesep]); % not necessarily used
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
[casFiles,sdnFileBegins]=specbatorderday(casFiles);

strOutPath=strrep(strInfoPath,['offline' filesep 'batch' filesep 'results'],['www' filesep 'plots' filesep 'batch']);
strOutputFile=[strOutPath sprintf('%4d_%2d_%2d_%s_ugrms_%s.csv',numYear,numMonth,numDay,strSensorID,strTag)];

for iFile=1:numFilesTotal
   strFile=casFiles{iFile};
   [sdn1,strPathPart,strNamePart,strExt,strVer]=locsdnfileparts(strFile);
   load(strFile)
   sdn=sdn1+(0:dT:dT*nCols(b)-dT)/86400;
   fprintf('\nfile %4d of %4d: with start time of %s',iFile,numFilesTotal,popdatestr(sdn1,0))
   otoResults=vehiclemoto(sdn,f,b,sHeader.CutoffFreq,strOutputFile);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sdn1,strPathPart,strNamePart,strExt,strVer]=locsdnfileparts(strFile);
[strPathPart,strNamePart,strExt,strVer]=fileparts(strFile);
sdn1=popdatenum(strrep([strNamePart(1:19) '.' strNamePart(21:23)],'_',','));
