
% Nominal ones
cIn={'12-Oct-1939,12:34:56.789';
   '10/12/1939,12:34:56.789';
   '1939:10:12:12:34:56.789';
   '1939:285:12:34:56.789'};

% Off-nominal ones
cIn={'12-Oct-1939,12:122:56.789';
   '10/32/1939,12:34:56.789';
   '1939:15:12:12:34:56.789';
   '1939:528:12:34:56.789'};

cOl={'01-Mar-1995,10:00:00.001';
   '03/01/1995,10:00:00.002';
   '1995:03:01:10:00:00.003';
   '1995:60:10:00:00.004'};

cFo={'dd-mmm-yyyy,HH:MM:SS.SSS';
   'MM/DD/YYYY,hh:mm:ss.sss';
   'YYYY:MM:DD:hh:mm:ss.sss';
   'YYYY:DOY:hh:mm:ss.sss'};

for i=1%1length(cIn)
   strInput=cIn{i};
   strOld=cOl{i};
   strFormat=cFo{i};
   fprintf('\n%s; %s; %s\n',strInput,strOld,strFormat)
   [strNeat,strMsg]=prettytimestring(strInput,strOld,strFormat);
   if isempty(strMsg)
      fprintf('\nVALID INPUT: %s\n',strNeat)
   else
      fprintf('\nNO CHANGE, REVERT TO: %s BECAUSE %s\n',strNeat,strMsg)
   end
   
end