function strPIMSfilename=parse1970filename(str1970filename);

%parse1970filename - Function to dissect 1970 filenames.
%
%strPIMSfilename=parse1970filename(str1970filename);
%
%Input: str1970filename - string for seconds-since-1-Jan-1970 relative filename
%
%Output: strPIMSfilename - string for PIMS-format filename
%         
%parse out :    strStart thru  strStop    . sensor
%example in: 949591965.5486-949592565.5575.121_e01

% written by: Ken Hrovat on 4/20/00
% $Id: parse1970filename.m 4160 2009-12-11 19:10:14Z khrovat $

%Find thru flag
indm=findstr(str1970filename,'-');
indp=findstr(str1970filename,'+');
if ( ~isempty(indm) & ~isempty(indp) )
   if ( length(indm)>1 | length(indp)>1 )
   error('unaccounted for case finding thru flag')
end
if isempty(indm)
   thru=str1970filename(indp);
   indt=indp;
elseif isempty(indp)
   thru=str1970filename(indm);
   indt=indm;
else
   error('unaccounted for case finding thru flag')
end

strStart=convert1970time(str1970filename(1:indt-1));

%Find last dot
indd=findstr(str1970filename,'.');
if isempty(indd) | length(indd)~=3
   error('number of dots must be exactly 3')
end

strStop=convert1970time(str1970filename(indt+1:indd-1));
sensor=str1970filename(indd+1:end);

strPIMSfilename=[strStart thru strStop '.' sensor];
