function gvt2csv(hFig,strCSVname);

strName=get(hFig,'name');
if ~strcmp(strName,'gvt3')
   disp('nothing done ... need a "gvt3" figure to work with')
   return
end
h=guihandles(hFig);
strTUnits=get(get(h.Axes31,'xlabel'),'str');
casColumn={'t','x','y','z'};
if hasstr('seconds',strTUnits)
   strTUnits='seconds';
else
   disp('nothing done ... expecting seconds for time units')
   return
end
hAx=[h.Axes11 h.Axes21 h.Axes31];
for i=1:length(hAx)
   hax=hAx(i);
   hLine=findobj(hax,'type','line');
   if length(hLine)~=1
      disp('nothing done ... expected one line for this axes')
      return
   end
   strGUnits=get(get(hax,'ylabel'),'str');
   if ~hasstr('(g)',strGUnits)
      disp('nothing done ... expecting units of g')
      return
   end
   if i==1
      t=get(hLine,'xdata');
      M=nan*ones(length(t),4);
      M(:,1)=t(:);
   end
   yd=get(hLine,'ydata');
   M(:,i+1)=yd(:);
   hy=get(hax,'ylabel');
   %figure
   %plot(t,yd)
   %xlabel(strTUnits)
   %ylabel(get(hy,'str'))
end

fid=fopen(strCSVname,'w');
if fid==-1
   fprintf('\nnothing done ... invalid fid for %s\n',strCSVname)
end
fprintf(fid,'%.3f,%.6e,%.6e,%.6e\n',M');
fclose(fid)
fprintf('\nWrote CSV file...\n%s\n',strCSVname);
