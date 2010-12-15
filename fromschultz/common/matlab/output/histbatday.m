function [mg95,cp95,fs,mgBins,sNBIG,sNumHoursBIG,sText]=histbatday(strSensor,Y,M,D,strSubdir,strTitle,blnSmall,varargin);

%HISTBATDAY - analyze padhist files
%
% ex.// Y=[2001 2001];
%       M=[6 6];
%       D=[28 29];
%       cSleep{1}=1:3;
%       cWake{1}=6:23;
%       cSleep{2}=1:5;
%       cWake{2}=7:23;
% maybe need something like this? [cSleep{1:14}]=deal([0:5]);
%
%[mg95,cp95,fs,mgBins,sNBIG,sNumHoursBIG,sText]=histbatday('121f02',2002,10,28,'padhist','Summary #2, Increment 4, Data Set #1',1,cSleep,cWake);
%[mg95,cp95,fs,mgBins,sNBIG,sNumHoursBIG,sText]=histbatday('121f02',2002,10,28,'padhist','Set 02-01, Increment 4',1,cSleep,cWake);
%
%Inputs: strSensor - string for sensor
%        Y,M,D - vectors for year, month, day (same size)
%        cSleep,cWake - cell array of hours for sleep and wake
%        strTitle - string for label of this set (like "Summary #2, Increment 4, Data Set #1")
%        strSubdir - string for subdirectory (like padhist or padfilthist)
%        blnSmall - scalar boolean for small [IAF] printouts; that is, use larger text
%
%Outputs: mg95 - scalar acceleration magnitude in mg that just gets us over 95th percentile
%         cp95 - scalar that gives the actual percentile value (just over 95)
%         fs - sample rate
%         mgBins - vector of bins for accel. mag. [in mg]
%         sNBIG - structure of # of occurrence values
%         sNumHoursBIG - structure of hour tally
%         sText - structure of text for call like:
%                 hHST=plotgen2d(mgBins,N(:),sText,'screen',[]);
%
%[mg95,cp95,fs,mgBins,sNBIG,sNumHoursBIG,sText]=histbatday(strSensor,Y,M,D,strSubdir,strTitle,blnSmall,cSleep,cWake);

%written by: Ken Hrovat on 7/30/00
% $Id: histbatday.m 4160 2009-12-11 19:10:14Z khrovat $

% Get category labels from input argument names & create empty structures
sNBIG=[];
sNumHoursBIG=[];
cLabels=cell(nargin-7,1);
for i=8:nargin
   str=inputname(i);
   strLabel=str(2:end);
   cLabels{i-7}=strLabel;
   sNBIG=setfield(sNBIG,strLabel,[]);
   sNumHoursBIG=setfield(sNumHoursBIG,strLabel,[]);
end

% Add ALL category
sNBIG=setfield(sNBIG,'All',[]);
sNumHoursBIG=setfield(sNumHoursBIG,'All',[]);

% For home grown LPF
if strcmp(strSubdir,'padfilthist')
   fc=input('Enter cutoff frequency for the lowpass filter: ');   
end

% Get prepath
[strHost,strRemote]=pophostname;
switch strHost
case 'pcwin'
   strPrePath='T:\offline\batch\results\';
case 'ra'
   strPrePath='/sdds/pims2/offline/batch/results/';
otherwise
   error(sprintf('unknown host %s',strHost))
end %switch strHost
u=filesep;

% Loop through each in set for this strTitle
for i=1:length(Y)
   y=Y(i);
   m=M(i);
   d=D(i);
   yyyy=num2str(y);
   mm=sprintf('%02d',m);
   dd=sprintf('%02d',d);
   strPathName=[strPrePath 'year' yyyy u 'month' mm u 'day' dd u strSensor u strSubdir u];
   isep=findstr(strPathName,filesep);
   strYM=[strPathName(isep(end-6)+5:isep(end-6)+8) '_' strPathName(isep(end-5)+6:isep(end-5)+7)];
   strDay=strPathName(isep(end-4)+4:isep(end-3)-1);
   if exist(strPathName)~=7
      fprintf('\nNO PATH: %s',strPathName)
   else
      fprintf('\nPATH: %s',strPathName)
      % Loop through hours in day
      for h=0:23
         strWild=sprintf('*h%02dh*',h);
         [filenames,details]=dirdeal([strPathName strWild]);
         if ~isempty(filenames)
            for j=1:length(filenames)
               strFile=filenames{j};
               ih=findstr(fliplr(strFile),'h');
               strFs=strFile(length(strFile)+2-ih:end-4);
               fs=str2num(strrep(strFs,'p','.'));
               load([strPathName strFile]);
               numFileHours=sum(dayNv)/fs/3600;
               if numFileHours > 1.333
                  error(sprintf('\n---- SKIP file: %s => + %.2f HOURS',strFile,numFileHours))
               else
                  if isempty(sNumHoursBIG.All)
                     fprintf('\nFIRST file: %s => adds %.2f hours for hour %02d to:',strFile,numFileHours,h)
                     sNBIG.All=dayNv;
                     sNumHoursBIG.All=numFileHours;
                     % Loop through each category's hours
                     for k=1:length(varargin)
                        strLabel=cLabels{k};
                        hours=varargin{k}{i};
                        if ismember(h,hours)
                           fprintf(' %s',strLabel)
                           if isempty(getfield(sNBIG,strLabel))
                              sNBIG=setfield(sNBIG,strLabel,dayNv);
                              sNumHoursBIG=setfield(sNumHoursBIG,strLabel,sum(dayNv)/fs/3600);
                           else
                              Nprevious=getfield(sNBIG,strLabel);
                              numHoursPrevious=getfield(sNumHoursBIG,strLabel);
                              sNBIG=setfield(sNBIG,strLabel,Nprevious+dayNv);
                              sNumHoursBIG=setfield(sNumHoursBIG,strLabel,numHoursPrevious+sum(dayNv)/fs/3600);
                           end
                        end
                     end
                     fprintf(' %s','All')
                  else
                     fprintf('\n    + file: %s => adds %.2f hours for hour %02d to:',strFile,numFileHours,h)
                     sNBIG.All=sNBIG.All+dayNv;
                     sNumHoursBIG.All=sNumHoursBIG.All+sum(dayNv)/fs/3600;
                     % Loop through each category's hours
                     for k=1:length(varargin)
                        strLabel=cLabels{k};
                        hours=varargin{k}{i};
                        if ismember(h,hours)
                           fprintf(' %s',strLabel)
                           if isempty(getfield(sNBIG,strLabel))
                              sNBIG=setfield(sNBIG,strLabel,dayNv);
                              sNumHoursBIG=setfield(sNumHoursBIG,strLabel,sum(dayNv)/fs/3600);
                           else
                              Nprevious=getfield(sNBIG,strLabel);
                              numHoursPrevious=getfield(sNumHoursBIG,strLabel);
                              sNBIG=setfield(sNBIG,strLabel,Nprevious+dayNv);
                              sNumHoursBIG=setfield(sNumHoursBIG,strLabel,numHoursPrevious+sum(dayNv)/fs/3600);
                           end
                        end
                     end
                     fprintf(' %s','All')
                  end
               end
            end
         end
      end
   end
end

fprintf('\n\n')

% Get text for plots
sText.strXType='Acceleration Magnitude';
sText.strXUnits='mg';
sText.casYStub={'Cumulative Percentage of Occurrence'};
sText.casYTypes={''};
sText.casYUnits={'%'};
if ~exist('fc')
   if strcmp(strSensor,'hirap')
      fc=100;
   else
      fc=fs/2.5;
   end
end
strCutoff=sprintf('%.1f Hz',fc);

% Loop through categories to plot each
cLabels=cappend(cLabels,'All');
for i=1:length(cLabels)
   strLabel=cLabels{i};
   
   N=getfield(sNBIG,strLabel);
   numHours=getfield(sNumHoursBIG,strLabel);
   
   cumPct=100*cumsum(N)/sum(N);
   i95plus=find(cumPct>=95);
   i95plus=i95plus(1);
   cp95=cumPct(i95plus);
   mg95=dayVV(i95plus)/1e-3;
   sText.casUL={strSensor,strCutoff,'',''};
   sText.casUR={sprintf('%.2f hours,',numHours),sprintf('%d',sum(N)),'samples',''};
   %sText.strComment={upper([strTitle ', ' strLabel]),sprintf('Approx. %.2f%% of Acceleration Magnitudes Were Below %.2f mg',cumPct(i95plus),dayVV(i95plus)/1e-3)};
   sText.strComment={upper([strTitle ', ' strLabel]),sprintf('Approx. %.2f%% of Acceleration Magnitudes Were Below %.2f mg',cp95,mg95)};
   sText.strTitle='';
   sText.casRS={{''},{''}};
   
   % Plot CPO
   mgBins=dayVV/1e-3;
   cumPct=cumPct(:);
   hCPO=plotgen2d(mgBins,cumPct,sText,'screen',[]);
   strFile1=strrep([strTitle '_' strSensor '_cpom_' lower(strLabel)],' ','');
   strFile1=strrep(strFile1,'#','');
   if blnSmall % fix fonts and the like for small print
      set(hCPO.TextUpperLeft1,'pos',[-0.07 1.10 0]);
      set(hCPO.TextUpperLeft2,'pos',[-0.07 1.07 0]);
      set(hCPO.TextUpperRight1,'pos',[1.06 1.10 0]);
      set(hCPO.TextUpperRight2,'pos',[1.06 1.07 0]);
      set(hCPO.TextUpperRight3,'pos',[1.06 1.04 0]);
      set([hCPO.TextUpperLeft1 hCPO.TextUpperLeft2 hCPO.TextUpperRight1 hCPO.TextUpperRight2 hCPO.TextUpperRight3],'fonts',16);
      set(hCPO.Line11,'linewidth',3);
      set(hCPO.Axes11,'pos',[0.11 0.095 0.81 0.8005]);
      hx=get(gca,'xlabel');hy=get(gca,'ylabel');
      set([hx hy],'fonts',20);
      set(hCPO.Axes11,'fonts',18);
      set(hCPO.TextTitle,'fonts',18);
      set(hCPO.TextComment,'fonts',18);
      set(hCPO.TextComment,'pos',[0.45 1.06 0]);
   end
   %iPound=findstr(strTitle,'#');
   %iBegin=iPound(1)+1;
   %iComma=findstr(strTitle,',');
   %iEnd=iComma(1)-1;
   numSummary=str2num(strTitle(5:6));
   strEPSpath=sprintf('T:/www/plots/grandsummary%02d/eps/',numSummary);
   if ~exist(strEPSpath,'dir')
      [status,strMsg]=pimsmkdir(strEPSpath);
   end
   strFile1=strrep(lower(strFile1),'summary','gs');
   strFile1=strrep(strFile1,'increment','inc');
   strFile1=strrep(strFile1,',','');
   strFilename=[strEPSpath strFile1];
   fprintf('\nprint to %s',strFilename)
   print('-depsc','-tiff','-r600',strFilename);
   close(gcf)
   
   % Add CSV table
   strCSVpath=strrep(strEPSpath,'eps','csv');
   if ~exist(strCSVpath,'dir')
      [status,strMsg]=pimsmkdir(strCSVpath);
   end
   [iLeft,iRight,strDelim]=finddelimited(strSensor,'.eps',strFilename,1);
   strCSVfile=[strrep(strFilename(1:iLeft-2),[filesep 'eps' filesep],[filesep 'csv' filesep]) '_95pct.csv'];
   if exist(strCSVfile)~=2
      fid=fopen(strCSVfile,'a');
      cas=cappend('Sensor',cLabels);
      cas=cappend(cas,'Hours');
      fprintf(fid,'%s,',cas{:});
      if i==1
         fprintf(fid,'\n%s,',strSensor);
      end
   else
      fid=fopen(strCSVfile,'a');
      if i==1
         fprintf(fid,'\n%s,',strSensor);
      end
   end
   if strcmp(strLabel,'All')
      fprintf(fid,'%.2f,%.2f',mg95,numHours);
   else
      fprintf(fid,'%.2f,',mg95);
   end
   fclose(fid);
   
end

sText.casYStub={'Number Of Occurrences'};
sText.casYUnits={'#'};
%save([strPathName sprintf('%d_%02d_%02d_%d_%02d_%02d_%s_%s_cpo',numYearStart,numMonthStart,numDayStart,numYearStop,numMonthStop,numDayStop,strSensor,strTitle)],'mgBins','N','sText');

if 0
   % Plot HST
   sText.casYStub={'Percentage of Occurrence'};
   pct=100*NALL(:)/sum(NALL);
   hHST=plotgen2d(mgBins,pct,sText,'screen',[]);
   strFile2=strrep(genimgfilename(sdnDays(1),strTitle,strSensor,'hst','vecmag',0,'eps'),'_000','');
   print('-depsc','-tiff','-r600',['T:\www\plots\grandsummary\eps\' lower(strFile2)]);
end

fprintf('\n\n')