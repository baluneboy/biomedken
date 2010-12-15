function sHandles=issoverlay(sHandles,lineColor,lineStyle,lineWidth);

switch lineStyle
case 'solid'
   lineStyle='-';
case 'dotted'
   lineStyle=':';
otherwise
   error('unknown style for ISS line')   
end
if strcmp(lineColor,'none')
   return
end
moto=otoissreq;
fiss=moto(:,1);
giss=moto(:,end);
[fiss,giss]=stairs(fiss,giss);
hAx=sHandles.AxesALL;
for i=1:length(hAx)
   axes(hAx(i))
   strAxTag=get(gca,'tag');
   strLineTag=strrep(strAxTag,'Axes','LineISS');
   strSuffix=strrep(strAxTag,'Axes','');
   hold on
   hLineISS=plot(fiss,giss);
   set(hLineISS,'tag',strLineTag);
   set(hLineISS,'color',lineColor,'linestyle',lineStyle','linewidth',lineWidth);
   sHandles=setfield(sHandles,[strLineTag strSuffix],hLineISS);
   hold off
end
