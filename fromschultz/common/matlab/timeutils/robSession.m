function session=robSession(subject, date)

%
% For a given date and subject, figure out if the session is dc1,dc2,dc3 or
% post3.  This relies on the existance of
% S:\data\upper\serob\sessions_robotics.csv';
% and the assumption that you are asking for robotics dates.  This
% function could be broadened in the future to handle other types of 
% collects.
%
% Input: subject (format: s9999test) date (format:yearmody_Day)
%
% Outputs a string 
%

% Author: Morgan Clond
% $Id: robSession.m 4160 2009-12-11 19:10:14Z khrovat $

% you have date in the format of year/month/day_day padded with zeros
year=date(1:4);
month=str2num(date(5:6)); %to get rid of the zeros
day=str2num(date(7:8));
%to get it in the format found in the csv reference...
strDate=strcat(num2str(month),'/',num2str(day),'/',year);

%...Hokay...

strFile='S:\data\upper\serob\sessions_robotics.csv';
[num,txt,raw]=xlsread(strFile);

session='unknown';
for i=1:length(txt)
    if strcmp(txt(i,3),strDate)==1 %yup that's the day
        if strcmp(txt(i,1),subject)==1 % yup that's the guy
            session=txt(i,2); 
            session=session{1};
            return
        end
    end
end
