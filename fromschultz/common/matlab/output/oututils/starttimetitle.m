function strTitle=starttimetitle(sHeader,sSearch,varargin);

%starttimetitle - generate string for start time title
%
%strTitle=starttimetitle(sHeader,sSearch);
%or
%strTitle=starttimetitle(sdnDataStart,strTimeBase,strTimeFormat);
%
%Inputs: sHeader - structure of header info including sdnDataStart
%        sSearch - structure of search criteria including strTimeBase & strTimeFormat
%
%        sdnDataStart - serial date number for start time
%        strTimeBase - string for time base ('GMT')
%        strTimeFormat - string for time format ('YYYY:MM:DD...')
%
%Output: strTitle - string for start time title

%Author: Ken Hrovat, 2/8/2001
% $Id: starttimetitle.m 4160 2009-12-11 19:10:14Z khrovat $
% modified by Hrovat on 11/15/2001 to get with report time string convention
% like this: GMT 15-November-2001, 319/12:15:58

if nargin==2
   sdnDataStart=sHeader.sdnDataStart;
   strTimeBase=sSearch.PathQualifiers.strTimeBase;
   strTimeFormat=sSearch.PathQualifiers.strTimeFormat;
elseif nargin==3
   sdnDataStart=sHeader;
   strTimeBase=sSearch;
   strTimeFormat=varargin{:};
else
   error('wrong nargin')
end
strTime=popdatestr(sdnDataStart,0);%strTimeFormat);
doy=dayofyear(sdnDataStart);
yyyy=year(sdnDataStart);
[iLeft,iRight,strMon]=finddelimited('-','-',strTime,1);
strFullMonthName=fullmonthname(strMon,yyyy);
strTime=[strTime(1:iLeft) strFullMonthName strTime(iRight:end)];
strTime=strrep(strTime,',',sprintf(', %03d/',doy));
strTitle=sprintf('Start %s %s',strTimeBase,strTime);
