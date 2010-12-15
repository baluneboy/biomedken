fs=100;
t=0:1/fs:1024*4;
x=rand(size(t));
y=rand(size(t));
z=rand(size(t));
fcstr='25';
fsstr=num2str(fs);
timechoice='s';
timestartstr='TIMESTARTSTR';
head='HEAD';
mission='MISSION';
coord='COORD';
ttl='TTL';
windchoice=5;
whichaxis=1;
whichaxisstr='x';
wstr='hanning';
nfft=512;
noverlap=0;
cmstr='pimsmap';
maxf=25;
clim=[-12 -6];
fig=figure;

[textt,hmetstart,cblabel,anch,ax1,cax1]=plot_1spec(t,x,y,z,fcstr,fsstr,...
			timechoice,timestartstr,head,mission,coord,ttl,windchoice,...
         whichaxis,whichaxisstr,wstr,nfft,noverlap,cmstr,maxf,clim,fig);
      
cTitle={'strComment';'[strTimeZero sprintf(''(%s, k = %d)'',strWindow,K)]'}      