function superspecbat(strCSVfile);

% Loop through lines of specbat CSV instruction file
fid=fopen(strCSVfile);
counter=0;
while 1
   strLine = fgetl(fid);
   if ~isstr(strLine), break, end
   counter=counter+1;
   iComma=findstr(strLine,',');
   strSubDir=strLine(1:iComma(1)-1);
   strSensorID=strLine(iComma(1)+1:iComma(2)-1);
   sdnStart=datenum(strLine(iComma(2)+1:iComma(3)-1));
   sdnStop=datenum(strLine(iComma(3)+1:iComma(4)-1));
   CLim=str2num(strLine(iComma(4)+1:iComma(5)-1));
   TLim=[0 0];
   TLim(2)=str2num(strLine(iComma(5)+1:iComma(6)-1));
   TTickMin=0;
   TTickStep=str2num(strLine(iComma(6)+1:iComma(7)-1));
   TTickMax=str2num(strLine(iComma(7)+1:end));
   TTick=TTickMin:TTickStep:TTickMax;
   fprintf(['\n%s, %s, from %s to %s, CLim=[%d %d], TLim=[%d %d], TTick=[ ' repmat('%d ',1,length(TTick)) ']'],strSensorID,strSubDir,datestr(sdnStart),datestr(sdnStop),CLim,TLim,TTick)
   t0=now;
   specbat(strSubDir,strSensorID,sdnStart,sdnStop,CLim,TLim,TTick);
   t1=now;
   fprintf('\nelapsed time: %.2f minutes',(t1-t0)*1440)
   fprintf('\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^')
end
fclose(fid);