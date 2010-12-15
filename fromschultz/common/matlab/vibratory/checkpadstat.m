function out=checkpadstat(strLabel,strSensor,strFirstDay,strLastDay,fs);

% script to check padstat routine

%out=checkpadstat(strPath,fs);

%out=checkpadstat('T:\offline\batch\results\year1995\month10\day20\headc\padstat',125);

out=-1;
u=filesep;

strBase='T:\offline\batch\results\';
sdnFirst=datenum(strFirstDay);
sdnLast=datenum(strLastDay);


fid=fopen('d:\temp\checkpadstat.csv','a');

for sdn=sdnFirst:sdnLast
   clear filenames
   y=year(sdn);
   m=month(sdn);
   d=day(sdn);
   strWild=sprintf('%syear%4d%smonth%02d%sday%02d%s%s%s%s%s*snellstats*.mat',strBase,y,u,m,u,d,u,strSensor,u,strLabel,u);
   [filenames,de]=dirdeal(strWild);
   for i=1:length(filenames)
      strFile=filenames{i};
      load([de(i).pathstr filesep strFile]);
      %eval(['sdnFileStart=datenum(' strrep(strFile(1:19),'_',',') ');']);
      %tdelta=(sdnPeakGMT-(sdnFileStart+peakIndex/fs/86400))*86400;
      %fprintf('%.2f sec delta for %s\n',tdelta,strFile)
      fprintf(fid,'%s,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n',strFile,count,peakIndex,peakValue,peakXpart,peakYpart,peakZpart,sdnPeakGMT,xSqSum,xSum,ySqSum,ySum,zSqSum,zSum);
      fprintf('%s\n',strFile);
   end
   fprintf(fid,'\n');
end

fclose(fid);
out=0;

!d:\temp\checkpadstat.csv