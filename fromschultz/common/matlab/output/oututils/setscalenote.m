function setscalenote(hAx,blnOn);

% hAx - axes handles
% blnOn - boolean: 1 turn note ON, 0 to turn note OFF

YSCALENOTE=' SEE Y-SCALES';
numAx=length(hAx);
if numAx==1
   return
end
for iAx=1:length(hAx)
   thishAx=hAx(iAx);
   hTitle=get(thishAx,'title');
   strTitle=get(hTitle,'str');
   if blnOn
      if ~hasstr(YSCALENOTE,strTitle)
         set(hTitle,'str',[strTitle YSCALENOTE]);
      end
   else
      set(hTitle,'str',strrep(strTitle,YSCALENOTE,''));
   end
end
