function spgseriesjoin(hFigs,fmin,fmax);

% spgseriesjoin(hFigs,fmin,fmax); % spgseriesjoin([1 2 3],100,120)
% 
%

% Author: Ken Hrovat
% $Id: spgseriesjoin.m 4160 2009-12-11 19:10:14Z khrovat $

strFormat=repmat(' %d',1,length(hFigs));
strFormat=sprintf('\n\nclose([%s ])\n\n',strFormat);
fprintf(strFormat,hFigs)

T=[];
B=[];

K=0;
HRS=0;
for i=1:length(hFigs)
   hFig=hFigs(i);
   h=guihandles(hFig);
   b=get(h.Image11,'cdata');
   sdn=get(h.Image11,'xdata');
   F=get(h.Image11,'ydata');
   iKeep=find(F>=fmin & F<=fmax);
   F=F(iKeep);
   B=[B b(iKeep,:)];
   T=[T sdn];
   [k,hrs]=locGetK(hFig);
   K=K+k;
   HRS=HRS+hrs;
end

figure(hFigs(1))
t=get(gca,'xlim');
t1=t(1);
figure(hFigs(end))
t=get(gca,'xlim');
t2=t(2);

hFigNew=copyobj(hFigs(1),0);

figure(hFigNew)
hax=gca;
him=findobj(hax,'type','image');
set(him,'cdata',B,'xdata',T,'ydata',F);

set(gca,'ylim',[fmin fmax]);

h=guihandles(hFigNew);
set(h.TextUpperRight3,'str',sprintf('Hanning, k = %d',K));
set(h.TextUpperRight4,'str',sprintf('Span = %.2f hours',HRS));

set(gca,'xlim',[t1 t2])
set(gca,'xtick',t1:4/24:t2)
dateaxis('x',15)
colorbar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [k,hrs]=locGetK(hFig);
h=guihandles(hFig);
str=char(get(h.TextUpperRight3,'str'));
iEqSp=findstr(str,'= ');
k=str2num(str(iEqSp+1:end));
str=char(get(h.TextUpperRight4,'str'));
iEqSp=findstr(str,'= ');
hrs=str2num(str(iEqSp+1:end-5));