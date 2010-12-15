function thisdatenum=poptimestr2num(strTime);

%POPTIMESTR2NUM - convert time string to serial date number.
%
%[startdatenum,stopdatenum]=padname2times(strFilename);
%
%Inputs: strTime - string for time of form 'YYYY_MM_DD_hh_mm_ss.sss'
%
%Output: thisdatenum - scalar for serial start day where 1 corresponds to 1-Jan-0000

% written by: Ken Hrovat on 4/26/00
% $Id: poptimestr2num.m 4160 2009-12-11 19:10:14Z khrovat $

%Get rid of underscores and decimal point
strJustNumbers=strTime(ismember(strTime,num2str(0:9)));

%Now the component numbers
Y=str2num(strJustNumbers(1:4));
M=str2num(strJustNumbers(5:6));
D=str2num(strJustNumbers(7:8));
h=str2num(strJustNumbers(9:10));
m=str2num(strJustNumbers(11:12));
s=str2double(strJustNumbers(13:17))/1000;

%Conversion from components to serial date number
thisdatenum=popdatenum(Y,M,D,h,m,s);

