function [month,day]=monthandday(year,doy);

%monthandday - function to return month and day given year and day of year
%              (see dayofyear)
%
%[month,day]=monthandday(year,doy);
%
%Inputs: year, doy - scalars for year and day of year
%
%Output: month, day - scalars for month and day of month

% author: Ken Hrovat, 10/12/2000
% $Id: monthandday.m 4160 2009-12-11 19:10:14Z khrovat $

cumSumDays=cumsum(eomday(year,1:12));
ind=find(cumSumDays>=doy);
if isempty(ind)
   error('day of year not within span of cumsum(eomdays)')
elseif doy<=31
   month=1;
   day=doy;
else
   month=ind(1);
   day=doy-cumSumDays(ind(1)-1);
end

%Note:
%doy=sum(eomday(year,1:month-1))+dayofmonth;
