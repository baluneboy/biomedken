function [y,mo,d,h,mi,s] = popdatevec(t,varargin);
%popdatevec Date components.
%   C = popdatevec(T) separates the components of date strings and date
%   numbers into date vectors containing [year month date hour mins
%   secs] as columns.  Date strings with 2 character years are interpreted
%   to be within the 100 years centered around the current year.
%
%   [Y,M,D,H,MI,S] = popdatevec(T) returns the components of the date
%   vector as individual variables.
%
%   [...] = DAVEVEC(T,PIVOTYEAR) uses the specified pivot year as the
%   starting year of the 100-year range in which a two-character year
%   resides.  The default pivot year is the current year minus 50 years.
%
%   Examples
%     d = '12/24/1984';
%     t = 725000.00;
%     c = popdatevec(d) or c = popdatevec(t) produce c = [1984 12 24 0 0 0].
%     [y,m,d,h,mi,s] = popdatevec(d) returns y=1984, m=12, d=24, h=0, mi=0, s=0.
%     c = popdatevec('5/6/03') produces c = [2003 5 6 0 0 0] until 2054.
%     c = popdatevec('5/6/03',1900) produces c = [1903 5 6 0 0 0].
%
%   See also popdatenum, popdatestr, CLOCK.

% adapted from datevec.m by Ken Hrovat
% $Id: popdatevec.m 4160 2009-12-11 19:10:14Z khrovat $

try
   
   [y,mo,d,h,mi,s] = datevec(t,varargin{:});
   
   if sum(ismember(t,':'))
      error('popdatevec dummy error: preferred handling of strings with single colon')      
   end
   
catch
   
   if nargin>1
      error(sprintf('%s: no pivotyear implementation for format of %s',mfilename,t));
   end
   
   [val,str,strPattern]=popdateform(t); % collapse digits and decimal pts to #
   
   switch lower(strPattern)
   case '#d#h#m#s' %'DDd HHh MMm SS.SSSs', dateform=-9;
      a=sscanf(t,'%fd%fh%fm%fs');
      [y,mo]=deal(NaN);
      d=a(1);h=a(2);mi=a(3);s=a(4);
   case '#:#:#:#' %'DD:HH:MM:SS.SSS', dateform=-8;
      a=sscanf(t,'%f:%f:%f:%f');
      [y,mo]=deal(NaN);
      d=a(1);h=a(2);mi=a(3);s=a(4);
   case '#:#:#' %'HH:MM:SS.SSS', dateform=-7;
      a=sscanf(t,'%f:%f:%f');
      [y,mo,d]=deal(NaN);
      h=a(1);mi=a(2);s=a(3);
   case '#:#' %'MM:SS.SSS', dateform=-6;
      a=sscanf(t,'%f:%f');
      [y,mo,d,h]=deal(NaN);
      mi=a(1);s=a(2);
   case '#' %'SS.SSS', dateform=-5;
      [y,mo,d,h,mi]=deal(NaN);
      s=sscanf(t,'%f');
   case '#:#:#:#:#' %'YYYY:DOY:hh:mm:ss.sss', dateform=-4;
      a=sscanf(t,'%f:%f:%f:%f:%f');
      y=a(1);DOY=a(2);h=a(3);mi=a(4);s=a(5);
      [mo,d]=monthandday(y,DOY);   
   case '#_#_#_#_#_#' %'YYYY_MM_DD_hh_mm_ss.sss', dateform = -3.1;
      a=sscanf(t,'%f_%f_%f_%f_%f_%f');
      y=a(1);mo=a(2);d=a(3);h=a(4);mi=a(5);s=a(6);
   case '#,#,#,#,#,#' %'YYYY,MM,DD,hh,mm,ss.sss', dateform = -3;
      a=sscanf(t,'%f,%f,%f,%f,%f,%f');
      y=a(1);mo=a(2);d=a(3);h=a(4);mi=a(5);s=a(6);
   case '#:#:#:#:#:#' %'YYYY:MM:DD:hh:mm:ss.sss', dateform = -2;
      a=sscanf(t,'%f:%f:%f:%f:%f:%f');
      y=a(1);mo=a(2);d=a(3);h=a(4);mi=a(5);s=a(6);
   case {'sdn','#/#/#,#:#:#','#-x-#,#:#:#'}
      %'MM/DD/YYYY,hh:mm:ss.sss', dateform = -1;
      %'dd-mmm-yyyy,HH:MM:SS.SSS', dateform = 0;
      % both of these were handled by datevec
   otherwise
      error(sprintf('Unknown format: %s into %s',t,mfilename))
   end %switch strPattern
   
end

% Make sure time part is properly rounded, the day number is within
% range, and the first five fields are integers.
c=[y mo d h mi s];
maxc = ones(size(c,1),1)*[24 60 59.9991];
[e,col] = find(any((c(:,4:6) >= maxc)')' | ...
   any((c(:,3) > eomday(c(:,1),c(:,2)))')' | ...
   any((c(:,1:5) ~= floor(c(:,1:5)))')');
if ~isempty(e)
   adjustSeconds=ceil(c(e,6)*1e3)/1e3;
   dn = datenum(c(e,1),c(e,2),c(e,3),c(e,4),c(e,5),adjustSeconds);
   t = datevec(dn);
   if dn < 1, % Time only
      c(e,4:6) = t(:,4:6);
   else
      c(e,:) = t;
      y=c(e,1);mo=c(e,2);d=c(e,3);h=c(e,4);mi=c(e,5);s=c(e,6);
   end
end

if nargout<=1
   y = c;
elseif nargout~=6;
   error('wrong nargout')
end
