%gaptest

dt=12;
fs=1/dt;
slice1Stop=datenum(0,0,0,0,0,0);
tdiffs=0:dt/6:4.4*dt;
tnext=zeros(size(tdiffs));
Nfill=zeros(size(tnext));
slice2Start=zeros(size(tdiffs));
for i=1:length(tdiffs)
   slice2Start(i)=datenum(0 ,0 ,0 ,0 ,0 ,tdiffs(i));
   [tn,Nf]=padtnext(slice1Stop,slice2Start(i),fs);
   tnext(i)=tn;
   Nfill(i)=Nf;
   fprintf('\nslice1Stop:  %s',popdatestr(slice1Stop,13))
   fprintf('\nslice2Start: %s',popdatestr(slice2Start(i),13))
   fprintf('\ntn:          %s',popdatestr(tn,13))
   fprintf('\n-------------------------------------------\n')
end

[y1,m1,d1,h1,mi1,s1]=datevec(slice1Stop);
[y2,m2,d2,h2,mi2,s2]=datevec(slice2Start);
[yn,mn,dn,hn,min,sn]=datevec(tnext);
tdiffs=s2-s1;
newtdiffs=sn-s1;
stairs(tdiffs/dt,newtdiffs/dt,'b-'),hold on,stairs(tdiffs/dt,newtdiffs/dt,'ro')

return

fs=500;
dt=1/fs;
SECPERDAY=86400;
[y,m,d,h,mi,s]=datevec(now);
s=fix(1e3*s)/1e3;
slice1Stop=datenum(y,m,d,h,mi,s);
tdiffs=0:dt/2:6*dt;
sdiff=s+fix(1e3*tdiffs)/1e3;
slice2Start=datenum(y,m,d,h,mi,sdiff);
tnext=zeros(size(slice2Start));
Nfill=zeros(size(tnext));
for i=1:length(slice2Start)
   [tn,Nf]=padtnext(slice1Stop,slice2Start(i),fs);
   tnext(i)=tn;
   Nfill(i)=Nf;
   fprintf('\nslice1Stop:  %s',popdatestr(slice1Stop))
   fprintf('\nslice2Start: %s',popdatestr(slice2Start(i)))
   fprintf('\ntn:          %s',popdatestr(tn))
   fprintf('\n-------------------------------------------\n')
end
