strLabel='Data Set #1';
strSubdir='padhist';

clear Y M D cSleep cWake; strSensor='121f02';
Y(1)=2001;M(1)=6;D(1)=26;cSleep{1}=[];cWake{1}=[13:23];
Y(2)=2001;M(2)=6;D(2)=27;cSleep{2}=[];cWake{2}=[12:23];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,strSubdir);

clear Y M D cSleep cWake; strSensor='121f03';
Y(1)=2001;M(1)=6;D(1)=27;cSleep{1}=[];cWake{1}=[12:23];
Y(2)=2001;M(2)=6;D(2)=28;cSleep{2}=[1:4];cWake{2}=[6:23];
Y(3)=2001;M(3)=6;D(3)=29;cSleep{3}=[1:6];cWake{3}=[7:23];
Y(4)=2001;M(4)=6;D(4)=30;cSleep{4}=[];cWake{4}=[19:23];
Y(5)=2001;M(5)=7;D(5)=1;cSleep{5}=[1:7];cWake{5}=[9:23];
Y(6)=2001;M(6)=7;D(6)=2;cSleep{6}=[1:6];cWake{6}=[9:23];
Y(7)=2001;M(7)=7;D(7)=5;cSleep{7}=[1:6];cWake{7}=[7:23];
Y(8)=2001;M(8)=7;D(8)=6;cSleep{8}=[1:6];cWake{8}=[10:23];
Y(9)=2001;M(9)=7;D(9)=7;cSleep{9}=[2:9];cWake{9}=[10:23];
Y(10)=2001;M(10)=7;D(10)=8;cSleep{10}=[5:11];cWake{10}=[12:17 20:23];
Y(11)=2001;M(11)=7;D(11)=9;cSleep{11}=[7:13];cWake{11}=[14:23];
Y(12)=2001;M(12)=7;D(12)=10;cSleep{12}=[];cWake{12}=[16:23];
Y(13)=2001;M(13)=7;D(13)=11;cSleep{13}=[];cWake{13}=[1:10];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,strSubdir);

clear Y M D cSleep cWake; strSensor='121f04';
Y(1)=2001;M(1)=6;D(1)=27;cSleep{1}=[];cWake{1}=[14:23];
Y(2)=2001;M(2)=6;D(2)=28;cSleep{2}=[];cWake{2}=[6:23];
Y(3)=2001;M(3)=6;D(3)=29;cSleep{3}=[1:6];cWake{3}=[7:23];
Y(4)=2001;M(4)=6;D(4)=30;cSleep{4}=[];cWake{4}=[19:23];
Y(5)=2001;M(5)=7;D(5)=1;cSleep{5}=[1:7];cWake{5}=[9:23];
Y(6)=2001;M(6)=7;D(6)=2;cSleep{6}=[1:5];cWake{6}=[8:23];
Y(7)=2001;M(7)=7;D(7)=5;cSleep{7}=[1:6];cWake{7}=[8:23];
Y(8)=2001;M(8)=7;D(8)=6;cSleep{8}=[1:6];cWake{8}=[8:23];
Y(9)=2001;M(9)=7;D(9)=7;cSleep{9}=[1:9];cWake{9}=[10:11 13:23];
Y(10)=2001;M(10)=7;D(10)=8;cSleep{10}=[5:11];cWake{10}=[12:19 20:23];
Y(11)=2001;M(11)=7;D(11)=9;cSleep{11}=[7:13];cWake{11}=[12:23];
Y(12)=2001;M(12)=7;D(12)=10;cSleep{12}=[];cWake{12}=[15:23];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,strSubdir);

clear Y M D cSleep cWake; strSensor='121f06';
Y(1)=2001;M(1)=6;D(1)=9;cSleep{1}=[2:5 6:8];cWake{1}=[9:23];
Y(2)=2001;M(2)=6;D(2)=10;cSleep{2}=[1:5];cWake{2}=[7:23];
Y(3)=2001;M(3)=6;D(3)=11;cSleep{3}=[1:6];cWake{3}=[7:23];
Y(4)=2001;M(4)=6;D(4)=12;cSleep{4}=[1:5];cWake{4}=[7:23];
Y(5)=2001;M(5)=6;D(5)=13;cSleep{5}=[1:6];cWake{5}=[7:23];
Y(6)=2001;M(6)=6;D(6)=14;cSleep{6}=[1:6];cWake{6}=[7:23];
Y(7)=2001;M(7)=6;D(7)=15;cSleep{7}=[1:6];cWake{7}=[7:23];
Y(8)=2001;M(8)=6;D(8)=16;cSleep{8}=[1:7];cWake{8}=[9:23];
Y(9)=2001;M(9)=6;D(9)=17;cSleep{9}=[1:6];cWake{9}=[9:23];
Y(10)=2001;M(10)=6;D(10)=18;cSleep{10}=[1:6];cWake{10}=[8:23];
Y(11)=2001;M(11)=6;D(11)=19;cSleep{11}=[1:6];cWake{11}=[8:23];
Y(12)=2001;M(12)=6;D(12)=20;cSleep{12}=[1:6];cWake{12}=[8:23];
Y(13)=2001;M(13)=6;D(13)=22;cSleep{13}=[];cWake{13}=[14:20];
Y(14)=2001;M(14)=6;D(14)=25;cSleep{14}=[];cWake{14}=[10:22];
Y(15)=2001;M(15)=6;D(15)=26;cSleep{15}=[1:3];cWake{15}=[13:16];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,strSubdir);


% comparison test between padfilthist and padhist
strSubdir='padhist';
strLabel='Unfiltered for Comparison Test (2001-07-05to09)';
clear Y M D cSleep cWake; strSensor='121f03';
Y(1)=2001;M(1)=7;D(1)=5;cSleep{1}=[1:6];cWake{1}=[7:23];
Y(2)=2001;M(2)=7;D(2)=6;cSleep{2}=[1:6];cWake{2}=[10:23];
Y(3)=2001;M(3)=7;D(3)=7;cSleep{3}=[2:9];cWake{3}=[10:23];
Y(4)=2001;M(4)=7;D(4)=8;cSleep{4}=[5:11];cWake{4}=[12:17 20:23];
Y(5)=2001;M(5)=7;D(5)=9;cSleep{5}=[7:13];cWake{5}=[14:23];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,strSubdir);
strSubdir='padfilthist';
strLabel='5 Hz Lowpass Filtered for Comparison Test (2001-07-05to09)';
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatday(strSensor,Y,M,D,cSleep,cWake,strLabel,strSubdir);