strLabel='Font Check';
strSubdir='padhist';

clear Y M D cSleep cWake; strSensor='121f02';
Y(1)=2001;M(1)=6;D(1)=26;cSleep{1}=[];cWake{1}=[13:23];
Y(2)=2001;M(2)=6;D(2)=27;cSleep{2}=[];cWake{2}=[12:23];                                                            % blnSmall
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,strSubdir,1);