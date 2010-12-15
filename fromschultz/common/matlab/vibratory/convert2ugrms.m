function convert2ugrms(hFig);

figure(hFig);
hYlab=get(gca,'ylabel');
strLab=get(hYlab,'str');
if strcmp(strLab,'RMS Acceleration ( mg_{RMS} )')
   hLines=findobj(hFig,'type','line');
   for i=1:length(hLines)
      hLine=hLines(i);
      set(hLine,'ydata',get(hLine,'ydata')/1e-3);
   end
   set(hYlab,'str','RMS Acceleration ( \mug_{RMS} )');
else
   warning('ylabel did not match expected string')
end
