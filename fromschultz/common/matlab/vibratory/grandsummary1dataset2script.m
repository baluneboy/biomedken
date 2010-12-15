strLabel='Data Set #2';
strSubdir='padhist';

clear Y M D cSleep cWake; strSensor='121f03';
Y(1)=2001;M(1)=7;D(1)=23;cSleep{1}=[];cWake{1}=[4:23];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');

clear Y M D cSleep cWake; strSensor='121f05';
Y(1)=2001;M(1)=7;D(1)=26;cSleep{1}=[1:5];cWake{1}=[6:23];
Y(2)=2001;M(2)=7;D(2)=27;cSleep{2}=[1:7];cWake{2}=[8:19];
Y(3)=2001;M(3)=7;D(3)=28;cSleep{3}=[2:8];cWake{3}=[9:23];
Y(4)=2001;M(4)=7;D(4)=29;cSleep{4}=[1:8];cWake{4}=[9:23];
Y(5)=2001;M(5)=7;D(5)=30;cSleep{5}=[1:7];cWake{5}=[8:11];
Y(6)=2001;M(6)=8;D(6)=1;cSleep{6}=[];cWake{6}=[22:23];
Y(7)=2001;M(7)=8;D(7)=2;cSleep{7}=[];cWake{7}=[8:23];
Y(8)=2001;M(8)=8;D(8)=3;cSleep{8}=[];cWake{8}=[9:11 16];
Y(9)=2001;M(9)=8;D(9)=7;cSleep{9}=[];cWake{9}=[14:23];
Y(10)=2001;M(10)=8;D(10)=8;cSleep{10}=[2:7];cWake{10}=[8:23];
Y(11)=2001;M(11)=8;D(11)=9;cSleep{11}=[2:5];cWake{11}=[9:21];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');

clear Y M D cSleep cWake; strSensor='121f06';
Y(1)=2001;M(1)=7;D(1)=26;cSleep{1}=[0:4];cWake{1}=[6:23];
Y(2)=2001;M(2)=7;D(2)=27;cSleep{2}=[3:4];cWake{2}=[8:19];
Y(3)=2001;M(3)=7;D(3)=28;cSleep{3}=[2:8];cWake{3}=[9:23];
Y(4)=2001;M(4)=7;D(4)=29;cSleep{4}=[1:7];cWake{4}=[8:23];
Y(5)=2001;M(5)=7;D(5)=30;cSleep{5}=[1:7];cWake{5}=[8:23];
Y(6)=2001;M(6)=8;D(6)=1;cSleep{6}=[];cWake{6}=[22:23];
Y(7)=2001;M(7)=8;D(7)=2;cSleep{7}=[];cWake{7}=[8:13 15:23];
Y(8)=2001;M(8)=8;D(8)=3;cSleep{8}=[];cWake{8}=[9:11 16];
Y(9)=2001;M(9)=8;D(9)=7;cSleep{9}=[];cWake{9}=[14:23];
Y(10)=2001;M(10)=8;D(10)=8;cSleep{10}=[2:7];cWake{10}=[8:23];
Y(11)=2001;M(11)=8;D(11)=9;cSleep{11}=[2:5];cWake{11}=[9:21];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
