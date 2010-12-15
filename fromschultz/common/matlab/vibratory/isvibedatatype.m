function bln=isvibedatatype(strDataType);

%isvibedatatype - true if header field, DataType, has 'sams' or 'hirap'
%
%bln=isvibedatatype(strDataType);
%
%Inputs: strDataType - string for data type
%
%Output: bln - boolean value 1/0 for "vibratory data"/not, respectively

%Author: Ken Hrovat, 6/5/2000
%$Id: isvibedatatype.m 4160 2009-12-11 19:10:14Z khrovat $

% Check for sams or hirap
if ( strcmp(strDataType(1:4),'sams') | strcmp(strDataType(end-4:end),'hirap') )
   bln=1;
else
   bln=0;
end