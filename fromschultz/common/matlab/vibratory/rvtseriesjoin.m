function rvtseriesjoin(hFigs);

strFormat=repmat(' %d',1,length(hFigs));
strFormat=sprintf('\n\nclose([%s ])\n\n',strFormat);
fprintf(strFormat,hFigs)

figure(hFigs(1));
t1=get(gca,'xlim');t1=t1(1);
figure(hFigs(end))
t2=get(gca,'xlim');t2=t2(2);

hFig=copyobj(hFigs(1),0);

figure(hFig)
hax=gca;
hLines=findobj(gca,'type','line');
[K,HRS]=locGetK(hFig);

for iLine=2:length(hFigs)
   h=guihandles(hFigs(iLine));
   [k,hrs]=locGetK(hFigs(iLine));
   K=K+k;
   HRS=HRS+hrs;
   hLine=copyobj(findobj(hFigs(iLine),'type','line'),hax);
   hLines=[hLines(:); hLine(:)];
end

h=guihandles(gcf);
set(h.TextUpperRight3,'str',sprintf('Hanning, k = %d',K));
set(h.TextUpperRight4,'str',sprintf('Span = %.2f hours',HRS));

% Nudge YLabels left where there's RMS subscript
hy=get(gca,'ylabel');
set(hy,'units','norm');
set(hy,'pos',[-0.07 0.5 0]);

set(gca,'xlim',[t1 t2])
set(gca,'xtick',t1:4/24:t2)
dateaxis('x',15)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [k,hrs]=locGetK(hFig);
h=guihandles(hFig);
str=char(get(h.TextUpperRight3,'str'));
iEqSp=findstr(str,'= ');
k=str2num(str(iEqSp+1:end));
str=char(get(h.TextUpperRight4,'str'));
iEqSp=findstr(str,'= ');
hrs=str2num(str(iEqSp+1:end-5));