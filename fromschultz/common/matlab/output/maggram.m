function [mg95,cp95,numHoursALL,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=maggram(strSensor,Y,M,D,strLabel,strSubdir);

%maggram - analyze padhist files
%
% ex.// Y=[2001 2001];
%       M=[6 6];
%       D=[28 29];
%
%[mg95,cp95,numHoursALL,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=maggram('121f03',Y,M,D,cSleep,cWake,'Data Set #1');
%
%Inputs: strSensor - string for sensor
%        Y,M,D - vectors for year, month, day (same size)
%        cSleep,cWake - cell array of hours for sleep and wake
%        strLabel - string for label of this set (like "Data Set #1")
%        strSubdir - string for subdirectory (like padhist or padfilthist)
%
%Outputs: mg95 - scalar acceleration magnitude in mg that just gets us over 95th percentile
%         cp95 - scalar that gives the actual percentile value (just over 95)
%         numHoursALL - scalar number of hours analyzed
%         fs - sample rate
%         mgBins - vector of bins for accel. mag. [in mg]
%         NSLEEP,NWAKE,NALL - vector of # of occurrence values
%         sText - structure of text for call like:
%                 hHST=plotgen2d(mgBins,N(:),sText,'screen',[]);
%
%[mg95,cp95,numHoursALL,fs,mgBins,,NSLEEP,NWAKE,NALL,sText]=maggram(strSensor,Y,M,D,cSleep,cWake,strLabel,strSubdir);

%written by: Ken Hrovat on 8/20/00
% $Id: maggram.m 4160 2009-12-11 19:10:14Z khrovat $

if strcmp(strSubdir,'padfilthist')
   fc=input('Enter cutoff frequency for the lowpass filter: ');   
end

[strHost,strRemote]=pophostname;
switch strHost
case 'pcwin'
   strPrePath='T:\offline\batch\results\';
case 'ra'
   strPrePath='/sdds/pims2/offline/batch/results/';
otherwise
   error(sprintf('unknown host %s',strHost))
end %switch strHost

NALL=[];
SDN=[];
u=filesep;
for i=1:length(Y)
   y=Y(i);
   m=M(i);
   d=D(i);
   yyyy=num2str(y);
   mm=sprintf('%02d',m);
   dd=sprintf('day%02d',d);
   strPathName=[strPrePath strSensor u yyyy '_' mm u dd u strSubdir u];
   isep=findstr(strPathName,filesep);
   strYM=strPathName(isep(end-4)+1:isep(end-3)-1);
   strDay=strPathName(isep(end-3)+4:isep(end-2)-1);
   if exist(strPathName)~=7
      fprintf('\nNO PATH: %s',strPathName)
   else
      fprintf('\nPATH: %s',strPathName)
      for h=0:23
         strWild=sprintf('*h%02dh*',h);
         [filenames,details]=dirdeal([strPathName strWild]);
         if ~isempty(filenames)
            for i=1:length(filenames)
               strFile=filenames{i};
               fs=str2num(strrep(strFile(35:end-4),'p','.'));
               load([strPathName strFile]);
               numFileHours=sum(dayNv)/fs/3600;
               if numFileHours > 1.333
                  error(sprintf('\n    SKIP file: %s => + %.2f HOURS',strFile,numFileHours))
               else
                  if ~(exist('numHoursALL')==1)
                     fprintf('\nFIRST file: %s => + %.2f hours',strFile,numFileHours)
                     NALL=dayNv(:);
                     SDN=datenum(y,m,d,h,0,0);
                     numHoursALL=numFileHours;
                  else
                     fprintf('\n    + file: %s => + %.2f hours',strFile,numFileHours)
                     NALL=[NALL dayNv(:)];
                     SDN=[SDN datenum(y,m,d,h,0,0)];
                     numHoursALL=numHoursALL+sum(dayNv)/fs/3600;
                  end
               end
            end
         end
      end
   end
end

return

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

for i={'ALL','SLEEP','WAKE'}
   
   str=char(i);
   
   if exist(['N' str])
      
      eval(['N=N' str ';'])
      eval(['numHours=numHours' str ';'])
      
      cumPct=100*cumsum(N)/sum(N);
      i95plus=find(cumPct>=95);
      i95plus=i95plus(1);
      cp95=cumPct(i95plus);
      mg95=dayVV(i95plus)/1e-3;
      sText.casUL={strSensor,strCutoff,'',''};
      sText.casUR={sprintf('Total Hours: %.2f',numHours),sprintf('Total Samples: %d',sum(N)),'',''};
      sText.strComment={upper([strLabel ', ' str ' Hours']),sprintf('Approx. %.2f%% of Acceleration Magnitudes Were Below %.2f mg',cumPct(i95plus),dayVV(i95plus)/1e-3)};
      sText.strTitle='';
      sText.casRS={{''},{''}};
      
      % Plot CPO
      mgBins=dayVV/1e-3;
      cumPct=cumPct(:);
      hCPO=plotgen2d(mgBins,cumPct,sText,'screen',[]);
      strFile1=strrep([strLabel '_' strSensor '_cpom_' lower(str)],' ','');
      strFile1=strrep(strFile1,'#','');
      print('-depsc','-tiff','-r600',['T:\www\plots\grandsummary\eps\' lower(strFile1)]);
      close(gcf)
      
   end
   
end

sText.casYStub={'Number Of Occurrences'};
sText.casYUnits={'#'};
%save([strPathName sprintf('%d_%02d_%02d_%d_%02d_%02d_%s_%s_cpo',numYearStart,numMonthStart,numDayStart,numYearStop,numMonthStop,numDayStop,strSensor,strLabel)],'mgBins','N','sText');

if 0
   % Plot HST
   sText.casYStub={'Percentage of Occurrence'};
   pct=100*N(:)/sum(N);
   hHST=plotgen2d(dayVV/1e-3,pct,sText,'screen',[]);
   strFile2=strrep(genimgfilename(sdnDays(1),strLabel,strSensor,'hst','vecmag',0,'eps'),'_000','');
   print('-depsc','-tiff','-r600',['T:\www\plots\grandsummary\eps\' lower(strFile2)]);
end

fprintf('\n\n')

