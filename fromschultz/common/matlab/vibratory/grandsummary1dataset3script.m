strLabel='Data Set #3';

clear Y M D cSleep cWake; strSensor='121f02';
Y(1)=2001;M(1)=8;D(1)=25;cSleep{1}=[0:5];cWake{1}=[7:17];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');

clear Y M D cSleep cWake; strSensor='121f05';
Y(1)=2001;M(1)=8;D(1)=24;cSleep{1}=[];cWake{1}=[15:17 22:23];
Y(2)=2001;M(2)=8;D(2)=25;cSleep{2}=[0:5];cWake{2}=[7:23];
Y(3)=2001;M(3)=9;D(3)=8;cSleep{3}=[0:6];cWake{3}=[7:10 21:23];
Y(4)=2001;M(4)=9;D(4)=9;cSleep{4}=[0:6];cWake{4}=[10:23];
Y(5)=2001;M(5)=9;D(5)=10;cSleep{5}=[2:6];cWake{5}=[7:10];
Y(6)=2001;M(6)=9;D(6)=11;cSleep{6}=[3:6];cWake{6}=[7:12];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');

clear Y M D cSleep cWake; strSensor='121f06';
Y(1)=2001;M(1)=8;D(1)=24;cSleep{1}=[0:6];cWake{1}=[7:23];
Y(2)=2001;M(2)=8;D(2)=25;cSleep{2}=[0:5];cWake{2}=[7:23];
Y(3)=2001;M(3)=9;D(3)=8;cSleep{3}=[0:6];cWake{3}=[7:23];
Y(4)=2001;M(4)=9;D(4)=9;cSleep{4}=[0:6];cWake{4}=[10:23];
Y(5)=2001;M(5)=9;D(5)=10;cSleep{5}=[0:6];cWake{5}=[7:9 21:23];
Y(6)=2001;M(6)=9;D(6)=11;cSleep{6}=[2:6];cWake{6}=[];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
