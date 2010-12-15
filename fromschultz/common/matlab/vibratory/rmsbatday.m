function rmsbatday(strLabel,strSensor,strFirstDay,strLastDay);

% rmsbatday(strLabel,strSensor,strFirstDay,strLastDay);
% rmsbatday('padstat','headc','20-Oct-1995','05-Nov-1995');
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

blnDebug=0;

% Initialize
countAll=0;
xSqSumAll=0;
xSumAll=0;
ySqSumAll=0;
ySumAll=0;
zSqSumAll=0;
zSumAll=0;
aMaxAll=-inf;

% Loop for directories (T:\offline\batch\results\year1995\month10\day20\headc\padstat)
strBase='t:\offline\batch\results\';
sdnFirst=datenum(strFirstDay);
sdnLast=datenum(strLastDay);
u=filesep;
for sdn=sdnFirst:sdnLast
   clear filenames
   y=year(sdn);
   m=month(sdn);
   d=day(sdn);
   strWild=sprintf('%syear%4d%smonth%02d%sday%02d%s%s%s%s%s*snellstats*.mat',strBase,y,u,m,u,d,u,strSensor,u,strLabel,u);
   [filenames,de]=dirdeal(strWild);
   len=length(filenames);
   if ~blnDebug, fprintf('%s,',datestr(sdn)), end
   %fprintf('%04d files for wildcard: %s\n',len,strWild)
   countDay=0;
   xSqSumDay=0;
   xSumDay=0;
   ySqSumDay=0;
   ySumDay=0;
   zSqSumDay=0;
   zSumDay=0;
   aMaxDay=-inf;
   for i=1:len
      strFile=filenames{i};
      load([de(i).pathstr strFile]);
      countDay=countDay+count;
      xSqSumDay=xSqSumDay+xSqSum;
      xSumDay=xSumDay+xSum;
      ySqSumDay=ySqSumDay+ySqSum;
      ySumDay=ySumDay+ySum;
      zSqSumDay=zSqSumDay+zSqSum;
      zSumDay=zSumDay+zSum;
      xPeak=peakXpart-(xSum/count);
      yPeak=peakYpart-(ySum/count);
      zPeak=peakZpart-(zSum/count);
      aMax=pimsrss(xPeak,yPeak,zPeak);
      if blnDebug
         fprintf('%s,%.5e,%.5e,%.5e,%.5e,%.5e,%.5e,%.5e,%.5e,%.5e,%.5e,%.5e,%.5e,%.5e\n',strFile,count,peakIndex,peakValue,peakXpart,peakYpart,peakZpart,sdnPeakGMT,xSqSum,xSum,ySqSum,ySum,zSqSum,zSum);
      end
      if aMax>aMaxDay, aMaxDay=aMax; if blnDebug, fprintf('aMaxDay is now: %g\n',aMaxDay), end, end
   end
   if aMaxDay>aMaxAll, aMaxAll=aMaxDay; end
   countAll=countAll+countDay;
   xSqSumAll=xSqSumAll+xSqSumDay;
   xSumAll=xSumAll+xSumDay;
   ySqSumAll=ySqSumAll+ySqSumDay;
   ySumAll=ySumAll+ySumDay;
   zSqSumAll=zSqSumAll+zSqSumDay;
   zSumAll=zSumAll+zSumDay;
   xUGRMSday=sqrt((xSqSumDay/countDay)-(xSumDay/countDay)^2)/1e-6;
   yUGRMSday=sqrt((ySqSumDay/countDay)-(ySumDay/countDay)^2)/1e-6;
   zUGRMSday=sqrt((zSqSumDay/countDay)-(zSumDay/countDay)^2)/1e-6;
   aUGRMSday=pimsrss(xUGRMSday,yUGRMSday,zUGRMSday);
   xUGRMSall=sqrt((xSqSumAll/countAll)-(xSumAll/countAll)^2)/1e-6;
   yUGRMSall=sqrt((ySqSumAll/countAll)-(ySumAll/countAll)^2)/1e-6;
   zUGRMSall=sqrt((zSqSumAll/countAll)-(zSumAll/countAll)^2)/1e-6;
   aUGRMSall=pimsrss(xUGRMSall,yUGRMSall,zUGRMSall);
   ugMaxDay=aMaxDay/1e-6;
   ugMaxAll=aMaxAll/1e-6;
   if ~blnDebug
      fprintf('%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.1f\n',xUGRMSday,yUGRMSday,zUGRMSday,aUGRMSday,ugMaxDay,xUGRMSall,yUGRMSall,zUGRMSall,aUGRMSall,ugMaxAll)
   end
end