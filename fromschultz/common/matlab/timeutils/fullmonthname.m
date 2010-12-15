function [str,doyFirst,doyLast]=fullmonthname(strMon,yyyy);

% fullmonthname - convert abbreviations for month to full string for month name &
%                 to get days of year for first and last days of month
%
%[str,doyFirst,doyLast]=fullmonthname(strMon,yyyy); %OR
%[str,doyFirst,doyLast]=fullmonthname(strMon); %use current year
%
%Inputs: yyyy - scalar year
%        strMon - string for month name abbreviation
%
%Outputs: str - string for full name of month
%         doyFirst - scalar day of year for first day of month
%         doyLast - scalar day of year for last day of month

% written by: Ken Hrovat on 11/15/2001
%$Id: fullmonthname.m 4160 2009-12-11 19:10:14Z khrovat $

if nargin==1
   yyyy=year(now);
end

switch lower(strMon)
case 'jan'
   str='January';m=1;
case 'feb'
   str='February';m=2;
case 'mar'
   str='March';m=3;
case 'apr'
   str='April';m=4;
case 'may'
   str='May';m=5;
case 'jun'
   str='June';m=6;
case 'jul'
   str='July';m=7;
case 'aug'
   str='August';m=8;
case 'sep'
   str='September';m=9;
case 'oct'
   str='October';m=10;
case 'nov'
   str='November';m=11;
case 'dec'
   str='December';m=12;
otherwise
   error('unrecognized 3-letter month abbrev.')
end
doyFirst=dayofyear(datenum(['1-' strMon '-' num2str(yyyy)]));
strLastDOM=num2str(eomday(yyyy,m));
doyLast=dayofyear(datenum([strLastDOM '-' strMon '-' num2str(yyyy)]));