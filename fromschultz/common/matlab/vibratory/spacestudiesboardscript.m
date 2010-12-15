strLabel='STS-112 Joint Ops';

clear Y M D cSleep cWake; strSensor='121f02';
Y(1)=2002;M(1)=10;D(1)=10;cSleep{1}=[0:6];cWake{1}=[7:23];
Y(2)=2002;M(2)=10;D(2)=11;cSleep{2}=[0:6];cWake{2}=[7:23];
Y(3)=2002;M(3)=10;D(3)=12;cSleep{3}=[0:6];cWake{3}=[7:23];
Y(4)=2002;M(4)=10;D(4)=13;cSleep{4}=[0:6];cWake{4}=[7:23];
Y(5)=2002;M(5)=10;D(5)=14;cSleep{5}=[0:6];cWake{5}=[7:23];
Y(6)=2002;M(6)=10;D(6)=15;cSleep{6}=[0:6];cWake{6}=[7:23];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');

strSensor='121f03';
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');

strSensor='121f04';
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');

strSensor='121f05';
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');