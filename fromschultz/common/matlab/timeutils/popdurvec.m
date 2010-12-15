function [d,h,mi,s] = popdurvec(t)
%POPDURVEC Date components (SEE "Adapted ..." PARAGRAPH BELOW)
%
%
%   [D,H,MI,S] = POPDURVEC(T) returns the components of the date
%   vector as individual variables.
%
%   C = POPDURVEC(T) separates the components of date strings and date
%   numbers into date vectors containing [days hour mins
%   secs] as columns.  If T is a date string, it must be in one of the
%   date formats 0,1,2,6,13,14, 15,16 (as defined by POPDATESTR).  Date
%   strings with 2 character years are interpreted as if they are in the
%   current century.
%
%   Example:
%     [d,h,mi,s] = popdurvec('38:01:02:03.456') returns d=38, h=1, mi=2, s=3.456
%
%   See also POPDATENUM, POPDATESTR, CLOCK.
%
% Adapted from popdatevec.m (which came from datevec.m) on 1/18/1999 by Ken Hrovat
% $Id: popdurvec.m 4160 2009-12-11 19:10:14Z khrovat $
% to work with string inputs of the form inputstring='dd:hh:mm:ss.sss') to yield
% output vector values of [days hours minutes seconds].  Other functionality carried
% over from popdatevec.m or datevec.m has not been verified.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.1.1.1 $  $Date: 2001/03/02 18:21:58 $


if nargin < 1
  error('Not enough input arguments.');
end

[date_row,date_col] = size(t);

if isstr(t)
  pm = -1; % means am or pm is not in datestr
  dts = zeros(date_row,6);
  siz = [date_row 1];
  for count = 1:date_row 
   % Convert date input to date vector
   % Initially, the six fields are all unknown.
   c(1,1:6) = NaN;
   d = [' ' lower(t(count,:)) ' '];
   
   % Replace 'a ', 'am', 'p ' or 'pm' with ': '.
   
   p = max(find(d == 'a' | d == 'p'));
   if ~isempty(p)
      if (d(p+1) == 'm' | d(p+1) == ' ') & d(p-1) ~= lower('e')
         pm = (d(p) == 'p');
         if d(p-1) == ' '
            d(p-1:p+1) = ':  ';
         else
            d(p:p+1) = ': ';
         end
      end
   end
   
  % Any remaining letters must be in the month field; interpret and delete them.
   p = find(isletter(d));
   if ~isempty(p)
      k = min(p);
      if d(k+3) == '.', d(k+3) = ' '; end
      M = ['jan'; 'feb'; 'mar'; 'apr'; 'may'; 'jun'; ...
           'jul'; 'aug'; 'sep'; 'oct'; 'nov'; 'dec'];
      c(2) = find(all((M == d(ones(12,1),k:k+2))'));
      d(p) = setstr(' '*ones(size(p)));
   end
   
   % Find all nonnumbers.
   
   p = find((d < '0' | d > '9') & (d ~= '.'));
   
   % Pick off and classify numeric fields, one by one.
   % Colons delineate hour, minutes and seconds.
   
   k = 1;
   while k < length(p)
      if d(p(k)) ~= ' ' & d(p(k)+1) == '-'
         f = str2num(d(p(k)+1:p(k+2)-1));
         k = k+1;
      else
         f = str2num(d(p(k)+1:p(k+1)-1));
      end
      if ~isempty(f)
         if d(p(k))==':' | d(p(k+1))==':'
            if isnan(c(3))
               c(3) = f;               % day
            elseif isnan(c(4))
               c(4) = f;             % hour
               if pm == 1 & f ~= 12 % Add 12 if pm specified and hour isn't 12
                  c(4) = f+12;
               elseif pm == 0 & f == 12
                  c(4) = 0;
               end
            elseif isnan(c(5))
               c(5) = f;             % minutes
            elseif isnan(c(6)) 
               c(6) = f;             % seconds
            else
               error(['Too many time fields in ' t])
            end
         elseif isnan(c(2))
            if f > 12
               error([num2str(f) ' is too large to be a month.'])
            end
            c(2) = f;                % month
         elseif isnan(c(3))
            c(3) = f;                % date
         elseif isnan(c(1))
            if (f >= 0) & (p(k+1)-p(k) == 3)
               clk = clock;
               c(1) = f + floor(clk(1)/100)*100;  % year in current century
            else
               c(1) = f;             % year
            end
         else
            error(['Too many date fields in ' t])
         end
      end
      k = k+1;
   end

   if sum(isnan(c)) >= 5
      error(['Cannot parse date ' t])
   end

   % If the any of the day fields have been set, set an unspecified
   % year to the current year
   if isnan(c(1)) & any(~isnan(c(2:3))), clk = clock; c(1) = clk(1); end
   
   % If any field has not been specified, set it to zero. 
   p = find(isnan(c));
   if ~isempty(p)
      c(p) = zeros(1,length(p));
   end

   dts(count,:) = c;
  end
  c = dts;
else
  siz = size(t);
  c = dvcore(86400*t);
end

% Make sure time part is properly rounded, the day number is within
% range, and the first five fields are integers.
maxc = ones(size(c,1),1)*[24 60 60];
[e,col] = find(any((c(:,4:6) >= maxc)')' | ...
               any((c(:,3:5) ~= floor(c(:,3:5)))')');
if ~isempty(e),
  dn = datenum(c(e,1),c(e,2),c(e,3),c(e,4),c(e,5),c(e,6));
  t = datevec(dn);
  if dn < 1, % Time only
    c(e,4:6) = t(:,4:6);
  else
    c(e,:) = t;
  end
end

if nargout <= 1
   %y = c;
   d=c;
else
  %y = reshape(c(:,1),siz);
  %mo = reshape(c(:,2),siz);
  d = reshape(c(:,3),siz);
  h = reshape(c(:,4),siz);
  mi = reshape(c(:,5),siz);
  s = reshape(c(:,6),siz);
end

if ( nargin==1 & length(t)==1 & ~isstr(t) & t<1 )
   d=0;
end

if ( nargin==1 & length(t)==1 & ~isstr(t) & d<t & d~=0 )
   error('unaccounted for case of daykeeping');
end



