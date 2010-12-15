function strTime=convert1970time(var1970,dateform);

%convert1970time - Function which converts string form of time in seconds
%                  relative to January 1, 1970 to the standard PIMS formatted string.
%
%strTime=convert1970time(str1970);
%
%Inputs: str1970 - string form of time in seconds 1-Jan-1970
%
%Output: strTime - string for time in standard PIMS format

% written by Ken Hrovat on 4/20/00
% modified by Eric Kelly on 3/19/01
% $Id: convert1970time.m 4160 2009-12-11 19:10:14Z khrovat $

% var1970 can be a number or a string, convert from string if not already number
if isstr(var1970)
   double1970 = str2num(var1970);
else
   double1970 = double(var1970);
end

% if 'dateform is not passed in, use default which is PIMS
if ~exist('dateform','var')
   dateform = -3.1;
end

%Convert 1970 seconds to days
daysince1970=double1970/86400;

%Determine MATLAB's serial datenum representation (which is relative to 1-Jan-0000)
d=daysince1970+datenum('1-Jan-1970');

strTime=popdatestr(d,dateform);
