function [labels,strDateform] = popdatestr(D,varargin)
%popdatestr String representation of date.
%
%str=popdatestr(D,DATEFORM);
%or
%[str,strDateform]=popdatestr(D,DATEFORM);
%
%   popdatestr(D,DATEFORM) converts a serial data number D (as returned by
%   popdatenum) into a date string.  The string is formatted according to the
%   format number or string DATEFORM (see table below).  By default,
%   DATEFORM is [not necessarily] 1, 16, or 0 depending on whether D contains
%   dates, times or both. Date strings with 2 character years are interpreted
%   to be within the 100 years centered around the current year.
%
%   popdatestr(D,DATEFORM,PIVOTYEAR) uses the specified pivot year as the
%   starting year of the 100-year range in which a two-character year
%   resides.  The default pivot year is the current year minus 50 years.
%   DATEFORM = -1 uses the default format.
%
%   DATEFORM #      strDateform               Example                  keyForDateform
%     -9           'DDd HHh MMm SS.SSSs'           29d 15h 45m 17.842s @#d#h#m#s
%     -8           'DD:HH:MM:SS.SSS'               29:15:45:17.842     @#:#:#:#
%     -7           'HH:MM:SS.SSS'                     15:45:17.842     @#:#:#
%     -6           'MM:SS.SSS'                           45:17.842     @#:#
%     -5           'SS.SSS'                                 17.842     @#
%     -4           'YYYY:DOY:hh:mm:ss.sss'    1995:60:15:45:17.842     @#:#:#:#:#
%     -3.1         'YYYY_MM_DD_hh_mm_ss.sss'  1995_03_01_15_45_17.842  @#_#_#_#_#_#
%     -3           'YYYY,MM,DD,hh,mm,ss.sss'  1995,03,01,15,45,17.842  @#,#,#,#,#,#
%     -2           'YYYY:MM:DD:hh:mm:ss.sss'  1995:03:01:15:45:17.842  @#:#:#:#:#:#
%     -1           'MM/DD/YYYY,hh:mm:ss.sss'  03/01/1995,15:45:17.842  @#/#/#,#:#:#
%      0           'dd-mmm-yyyy,HH:MM:SS.SSS' 01-Mar-1995,15:45:17.842 @#-x-#,#:#:#
%      1             'dd-mmm-yyyy'            01-Mar-1995  
%      2             'mm/dd/yy'               03/01/95     
%      3             'mmm'                    Mar          
%      4             'm'                      M            
%      5             'mm'                     3            
%      6             'mm/dd'                  03/01        
%      7             'dd'                     1            
%      8             'ddd'                    Wed          
%      9             'd'                      W            
%     10             'yyyy'                   1995         
%     11             'yy'                     95           
%     12             'mmmyy'                  Mar95        
%     13             'HH:MM:SS'               15:45:17     
%     14             'HH:MM:SS PM'             3:45:17 PM  
%     15             'HH:MM'                  15:45        
%     16             'HH:MM PM'                3:45 PM     
%     17             'QQ-YY'                  Q1-96        
%     18             'QQ'                     Q1           
%
%   See also datestr, date, popdatenum, popdatevec.

% Adapted from MATLAB datestr.m function by Ken Hrovat 1/16/99
% $Id: popdatestr.m 4160 2009-12-11 19:10:14Z khrovat $

blnDebug=0;

try
   
   labels = datestr(D,varargin{:});
   
   if any(ismember(labels,'-/'))
      %popdatestr dummy error: preferred handling of strings with dash or slash     
      error('MyErrorDashSlash')      
   end
   if ( hasstr(labels,' AM') | hasstr(labels,' PM') )
      %popdatestr dummy error: preferred handling of strings with AMPM     
      error('MyErrorAMPM')      
   end
   
catch
   
   if nargin < 2
      [dateform,strDateform,strPattern]=popdateform(D);
   elseif nargin==2
      dateform=varargin{1};
   else
      error('wrong nargin');
   end
   
   % Don't ask why we need this
   if ( ~isstr(D) & second(D)>59.999 )
      secAdd=1e-4;
      if blnDebug, fprintf('\npopdatestr anticipated problem for sdn input: %.15f, so added %.1e sec.\n',D,secAdd), end
      D=D+(secAdd/86400);
   end
      
   [y,mo,d,h,mi,s] = popdatevec(D);
   
   dateform=num2str(dateform);
   strDateform=strrep(dateform,' ','');
   
   switch lower(strDateform)
   case {'dddhhhmmmss.ssss','-9'}
      labels=sprintf('%dd %dh %dm %0.3fs',d,h,mi,s);
   case {'dd:hh:mm:ss.sss','-8'}
      labels=sprintf('%d:%02d:%02d:%06.3f',d,h,mi,s);
   case {'hh:mm:ss.sss','-7'}
      labels=sprintf('%02d:%02d:%06.3f',h,mi,s);
   case {'mm:ss.sss','-6'}
      labels=sprintf('%02d:%06.3f',mi,s);
   case {'ss.sss','-5'}
      labels=sprintf('%06.3f',s);
   case {'yyyy:doy:hh:mm:ss.sss','-4'}
      sdn=datenum(y,mo,d,h,mi,s);
      doy=dayofyear(sdn);
      labels=sprintf('%04d:%03d:%02d:%02d:%06.3f',y,doy,h,mi,s);
   case {'yyyy_mm_dd_hh_mm_ss.sss','-3.1'}
      labels=sprintf('%04d_%02d_%02d_%02d_%02d_%06.3f',y,mo,d,h,mi,s);
   case {'yyyy,mm,dd,hh,mm,ss.sss','-3'}
      labels=sprintf('%04d,%02d,%02d,%02d,%02d,%06.3f',y,mo,d,h,mi,s);
   case {'yyyy:mm:dd:hh:mm:ss.sss','-2'}
      labels=sprintf('%04d:%02d:%02d:%02d:%02d:%06.3f',y,mo,d,h,mi,s);
   case {'mm/dd/yyyy,hh:mm:ss.sss','-1'}
      labels=sprintf('%02d/%02d/%04d,%02d:%02d:%06.3f',mo,d,y,h,mi,s);
   case {'dd-mmm-yyyy,hh:mm:ss.sss','0'}
      strMonth=datestr(sprintf('%d/%d/%d',mo,d,y),3);
      labels=sprintf('%02d-%s-%04d,%02d:%02d:%06.3f',d,strMonth,y,h,mi,s);
   otherwise
      error(sprintf('unknown date format: %s',strDateform))
   end %switch dateform
   
   % clean up some NaN cases
   ind=findstr(labels,'NaN');
   if ~isempty(ind)
      labels(1:ind(end)+3)=[];
   end
   
end

if ( blnDebug & hasstr(':6',labels) )
   fprintf('\npopdatestr had a problem with minutes or seconds for sdn input: %.15f\n',D)
end