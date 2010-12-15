strLabel='Data Set #5 Check';

clear Y M D cSleep cWake; strSensor='121f03';

clear theMovie

Y(1)=2001;M(1)=12;D(1)=16;cSleep{1}=[0:6];cWake{1}=[7:23];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
theMovie(1)=getframe;

Y(2)=2001;M(2)=12;D(2)=17;cSleep{2}=[0:5];cWake{2}=[7:22];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
theMovie(2)=getframe;

Y(3)=2001;M(3)=12;D(3)=18;cSleep{3}=[0:5];cWake{3}=[7:22];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
theMovie(3)=getframe;

Y(4)=2001;M(4)=12;D(4)=19;cSleep{4}=[0:4];cWake{4}=[18:22];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
theMovie(4)=getframe;

Y(5)=2001;M(5)=12;D(5)=20;cSleep{5}=[];cWake{5}=[6:22];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
theMovie(5)=getframe;

Y(6)=2001;M(6)=12;D(6)=21;cSleep{6}=[0:2];cWake{6}=[6:9 17:23];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
theMovie(6)=getframe;

Y(7)=2001;M(7)=12;D(7)=22;cSleep{7}=[0:6];cWake{7}=[7:22];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
theMovie(7)=getframe;

Y(8)=2001;M(8)=12;D(8)=23;cSleep{8}=[0:6];cWake{8}=[7:22];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
theMovie(8)=getframe;

Y(9)=2001;M(9)=12;D(9)=24;cSleep{9}=[0:6];cWake{9}=[7:22];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
theMovie(9)=getframe;

Y(10)=2001;M(10)=12;D(10)=25;cSleep{10}=[1:4];cWake{10}=[];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');
theMovie(10)=getframe;

return

Y(11)=2002;M(11)=1;D(11)=2;cSleep{11}=[];cWake{11}=[12:23];
Y(12)=2002;M(12)=1;D(12)=3;cSleep{12}=[0:6 22:23];cWake{12}=[9:21];
Y(13)=2002;M(13)=1;D(13)=4;cSleep{13}=[0:2];cWake{13}=[8:14];
Y(14)=2002;M(14)=1;D(14)=5;cSleep{14}=[];cWake{14}=[22:23];
Y(15)=2002;M(15)=1;D(15)=6;cSleep{15}=[5:9];cWake{15}=[0:4 10:23];
Y(16)=2002;M(16)=1;D(16)=7;cSleep{16}=[2:8];cWake{16}=[0:1 10:23];
Y(17)=2002;M(17)=1;D(17)=8;cSleep{17}=[2:9];cWake{17}=[0:1 10:23];
Y(18)=2002;M(18)=1;D(18)=9;cSleep{18}=[5:12];cWake{18}=[0:4 13:23];
Y(19)=2002;M(19)=1;D(19)=10;cSleep{19}=[5:12];cWake{19}=[0:4 13:23];
Y(20)=2002;M(20)=1;D(20)=11;cSleep{20}=[5:12];cWake{20}=[0:4 13:23];
Y(21)=2002;M(21)=1;D(21)=12;cSleep{21}=[6:13];cWake{21}=[1:4 14:23];
Y(22)=2002;M(22)=1;D(22)=13;cSleep{22}=[6:13];cWake{22}=[0:4 14:23];
Y(23)=2002;M(23)=1;D(23)=14;cSleep{23}=[5:12];cWake{23}=[0:4 17:19];
Y(24)=2002;M(24)=1;D(24)=15;cSleep{24}=[8:15];cWake{24}=[16:22];
Y(25)=2002;M(25)=1;D(25)=16;cSleep{25}=[0:6];cWake{25}=[8:22];
Y(26)=2002;M(26)=1;D(26)=17;cSleep{26}=[0:6];cWake{26}=[7:22];
Y(27)=2002;M(27)=1;D(27)=18;cSleep{27}=[0:6];cWake{27}=[7:21];
Y(28)=2002;M(28)=1;D(28)=19;cSleep{28}=[0:3];cWake{28}=[8:22];
Y(29)=2002;M(29)=1;D(29)=20;cSleep{29}=[0:7];cWake{29}=[8:10 11:22];
Y(30)=2002;M(30)=1;D(30)=23;cSleep{30}=[0:6];cWake{30}=[7:23];
Y(31)=2002;M(31)=1;D(31)=24;cSleep{31}=[0:5];cWake{31}=[7:13 17:20];
Y(32)=2002;M(32)=1;D(32)=25;cSleep{32}=[0:3 5:7];cWake{32}=[8:23];
Y(33)=2002;M(33)=1;D(33)=26;cSleep{33}=[4:9 10 11];cWake{33}=[0:2 12:23];
Y(34)=2002;M(34)=1;D(34)=27;cSleep{34}=[0:7];cWake{34}=[8:22];
Y(35)=2002;M(35)=1;D(35)=28;cSleep{35}=[0:7];cWake{35}=[8:22];
Y(36)=2002;M(36)=1;D(36)=29;cSleep{36}=[0:6];cWake{36}=[7:22];
Y(37)=2002;M(37)=1;D(37)=30;cSleep{37}=[0:6];cWake{37}=[7:22];
Y(38)=2002;M(38)=1;D(38)=31;cSleep{38}=[0:6];cWake{38}=[7:23];
Y(39)=2002;M(39)=2;D(39)=1;cSleep{39}=[0:6];cWake{39}=[7:23];
Y(40)=2002;M(40)=2;D(40)=2;cSleep{40}=[1:6];cWake{40}=[8:23];
Y(41)=2002;M(41)=2;D(41)=3;cSleep{41}=[0:7];cWake{41}=[8:23];
Y(42)=2002;M(42)=2;D(42)=4;cSleep{42}=[0:5];cWake{42}=[7:13];
Y(43)=2002;M(43)=2;D(43)=5;cSleep{43}=[];cWake{43}=[12:22];
Y(44)=2002;M(44)=2;D(44)=6;cSleep{44}=[0:5];cWake{44}=[7:23];
Y(45)=2002;M(45)=2;D(45)=7;cSleep{45}=[0:6];cWake{45}=[7:22];
Y(46)=2002;M(46)=2;D(46)=8;cSleep{46}=[0:6];cWake{46}=[7:22];
Y(47)=2002;M(47)=2;D(47)=9;cSleep{47}=[0:6];cWake{47}=[8:23];
Y(48)=2002;M(48)=2;D(48)=10;cSleep{48}=[0:7];cWake{48}=[8:22];
Y(49)=2002;M(49)=2;D(49)=14;cSleep{49}=[0:6];cWake{49}=[7:22];
Y(50)=2002;M(50)=2;D(50)=15;cSleep{50}=[0:6];cWake{50}=[7:22];
Y(51)=2002;M(51)=2;D(51)=16;cSleep{51}=[0:6];cWake{51}=[8:23];
Y(52)=2002;M(52)=2;D(52)=17;cSleep{52}=[0:7];cWake{52}=[8:23];
Y(53)=2002;M(53)=2;D(53)=18;cSleep{53}=[0:6];cWake{53}=[7:22];
Y(54)=2002;M(54)=2;D(54)=19;cSleep{54}=[0:6];cWake{54}=[7:21];
Y(55)=2002;M(55)=2;D(55)=20;cSleep{55}=[0:5];cWake{55}=[6:23];
Y(56)=2002;M(56)=2;D(56)=21;cSleep{56}=[0:5];cWake{56}=[6:22];
Y(57)=2002;M(57)=2;D(57)=22;cSleep{57}=[0:6];cWake{57}=[8:23];
Y(58)=2002;M(58)=2;D(58)=23;cSleep{58}=[0:6];cWake{58}=[8:21];
Y(59)=2002;M(59)=2;D(59)=24;cSleep{59}=[];cWake{59}=[9:22];
Y(60)=2002;M(60)=2;D(60)=25;cSleep{60}=[0:6];cWake{60}=[7:22];
Y(61)=2002;M(61)=2;D(61)=26;cSleep{61}=[0:6];cWake{61}=[7:22];
Y(62)=2002;M(62)=2;D(62)=27;cSleep{62}=[0:5];cWake{62}=[7:22];
Y(63)=2002;M(63)=2;D(63)=28;cSleep{63}=[0:6];cWake{63}=[8:14];
Y(64)=2002;M(64)=3;D(64)=12;cSleep{64}=[];cWake{64}=[20:23];
Y(65)=2002;M(65)=3;D(65)=13;cSleep{65}=[3:5];cWake{65}=[0:2 6:15 18:23];
Y(66)=2002;M(66)=3;D(66)=14;cSleep{66}=[0:6];cWake{66}=[7:23];
Y(67)=2002;M(67)=3;D(67)=15;cSleep{67}=[0:6];cWake{67}=[7:23];
Y(68)=2002;M(68)=3;D(68)=16;cSleep{68}=[0:7];cWake{68}=[8:22];
Y(69)=2002;M(69)=3;D(69)=17;cSleep{69}=[0:7];cWake{69}=[8:21];
Y(70)=2002;M(70)=3;D(70)=18;cSleep{70}=[0:6];cWake{70}=[8:17];
Y(71)=2002;M(71)=3;D(71)=19;cSleep{71}=[];cWake{71}=[16:23];
Y(72)=2002;M(72)=3;D(72)=21;cSleep{72}=[3:7];cWake{72}=[8:23];
Y(73)=2002;M(73)=3;D(73)=22;cSleep{73}=[0:6];cWake{73}=[8:23];
Y(74)=2002;M(74)=3;D(74)=23;cSleep{74}=[0:7];cWake{74}=[8:23];
Y(75)=2002;M(75)=3;D(75)=24;cSleep{75}=[0:7];cWake{75}=[8:23];
Y(76)=2002;M(76)=3;D(76)=25;cSleep{76}=[3:10];cWake{76}=[0:2 11:12 16:17];
Y(77)=2002;M(77)=3;D(77)=29;cSleep{77}=[0:6];cWake{77}=[7:9 16:23];
Y(78)=2002;M(78)=3;D(78)=30;cSleep{78}=[1:8];cWake{78}=[9:22];
Y(79)=2002;M(79)=3;D(79)=31;cSleep{79}=[0:7];cWake{79}=[8:22];
Y(80)=2002;M(80)=4;D(80)=1;cSleep{80}=[0:6];cWake{80}=[7:16];
Y(81)=2002;M(81)=4;D(81)=3;cSleep{81}=[];cWake{81}=[16:22];
Y(82)=2002;M(82)=4;D(82)=4;cSleep{82}=[0:5];cWake{82}=[7:23];
Y(83)=2002;M(83)=4;D(83)=5;cSleep{83}=[0:6];cWake{83}=[7:18];
Y(84)=2002;M(84)=4;D(84)=6;cSleep{84}=[];cWake{84}=[19:23];
Y(85)=2002;M(85)=4;D(85)=7;cSleep{85}=[0:7];cWake{85}=[8:22];
Y(86)=2002;M(86)=4;D(86)=8;cSleep{86}=[0:6];cWake{86}=[11:14];
[mg95,cp95,numHoursAll,fs,mgBins,NSLEEP,NWAKE,NALL,sText]=histbatdaymov(strSensor,Y,M,D,cSleep,cWake,strLabel,'padhist');