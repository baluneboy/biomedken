function day=dayofyear(sdn);

%dayofyear - function to return number of days into year
%            for given serial date number input (or string
%            input -- see popdatevec)
%
%day=dayofyear(sdn);
%
%Inputs: sdn - scalar for serial date number (or string
%                                        see popdatevec)
%
%Output: day - scalar for number of days into year

% author: Ken Hrovat, 10/11/2000
% $Id: dayofyear.m 4160 2009-12-11 19:10:14Z khrovat $

% Get 6 components
[year,month,dayofmonth,h,m,s]=popdatevec(sdn);

day=sum(eomday(year,1:month-1))+dayofmonth;
