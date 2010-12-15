function n = popdatenum(y,varargin)
%popdatenum Serial date number.
%   N = popdatenum(S) converts the string S into a serial date number.
%   Date numbers are serial days where 1 corresponds to 1-Jan-0000.
%   The string S must be in one of the date formats 0,1,2,6,13,14,
%   15,16 (as defined by DATESTR). Date strings with 2 character years
%   are interpreted to be within the 100 years centered around the 
%   current year.
%
%   N = popdatenum(S,PIVOTYEAR) uses the specified pivot year as the
%   starting year of the 100-year range in which a two-character year
%   resides.  The default pivot year is the current year minus 50 years.
%
%   N = popdatenum(Y,M,D) returns the serial date number for
%   corresponding elements of the Y,M,D (year,month,day) arrays.
%   Y,M, and D must be arrays of the same size (or any can be a scalar).
%
%   N = popdatenum(Y,M,D,H,MI,S) returns the serial date number for
%   corresponding elements of the Y,M,D,H,MI,S (year,month,hour,
%   minute,second) arrays values.  Y,M,D,H,MI,and S must be arrays of
%   the same size (or any can be a scalar).  Values outside the normal
%   range of each array are automatically carried to the next unit (for
%   example month values greater than 12 are carried to years).
%
%   Examples:
%       n = popdatenum('19-May-1995') returns n = 728798.
%       n = popdatenum(1994,12,19) returns n = 728647.
%       n = popdatenum(1994,12,19,18,0,0) returns n = 728647.75.
%
%   See also NOW, popdatestr, popdatevec.

% adapted from datenum.m by Ken Hrovat
% $Id: popdatenum.m 4160 2009-12-11 19:10:14Z khrovat $

try
   
   n = datenum(y,varargin{:});
   
catch
   
   if nargin == 1
      if isstr(y)
         c = popdatevec(y); % here is key difference from datenum.m
      else 
         n = y; 
         return
      end
      y=c(:,1);mo=c(:,2);d=c(:,3);h=c(:,4);mi=c(:,5);s=c(:,6);
   else
      error('wrong nargin')
   end
   
   sizes = [size(y);size(mo);size(d);size(h);size(mi);size(s)];
   row_index = find(sizes(:,1) ~= sizes(1,1) & sizes(:,1) ~= 1);
   col_index = find(sizes(:,2) ~= sizes(2,2) & sizes(:,2) ~= 1);
   if ~isempty(row_index) | ~isempty(col_index)
      error('Y,M,D,H,MI,and S must all be the same size.')
   end
   
   % Make sure mo is in the range 1 to 12.
   mo(mo==0) = 1;
   y = y + floor((mo-1)/12);
   mo = rem(mo-1,12)+1;
   
   % Running total of days per month
   cumdpm = cumsum([0;31;28;31;30;31;30;31;31;30;31;30;31]); 
   
   % result = (365 days/year)*(number of years) + number of leap years ...
   %      + days in previous months + days in this month + fraction of a day.
   n = 365.*y + ...                   % Convert year, month, day to date number
      ceil(y/4)-ceil(y/100)+ceil(y/400) + reshape(cumdpm(mo),size(mo)) + ...
      ((mo > 2) & ((rem(y,4) == 0 & rem(y,100) ~= 0) | rem(y,400) == 0)) + d;
   
   if any(h~=0) | any(mi~=0) | any(s~=0)
      n = n + (h.*3600+mi.*60+s)./86400;
   end
   
end

