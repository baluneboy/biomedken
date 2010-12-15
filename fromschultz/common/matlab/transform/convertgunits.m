function sf=convertgunits(strOldUnits,strNewUnits);

%convertgunits - return scale factor for converting g (engineering) units
%
%sf=convertgunits(strOldUnits,strNewUnits);
%
%Inputs: strOldUnits - string for old g units to convert FROM { 'g' | 'millig' | 'microg' }
%        strNewUnits - string for new g units to convert TO   { 'g' | 'millig' | 'microg' }
%
%Outputs: sf - scalar scale factor to multiply old value (in strOldUnits) by to get new value
%             (in strNewUnits)

%Author: Ken Hrovat, 2/7/2001
% $Id: convertgunits.m 4160 2009-12-11 19:10:14Z khrovat $

if strcmp(strOldUnits,strNewUnits)
   sf=1;
else
   sf1=double(convert(1*units(strrep(strOldUnits,'g','')),'g'));
   sf2=double(convert(1*units(strrep(strNewUnits,'g','')),'g'));
   sf=sf1/sf2;
end
