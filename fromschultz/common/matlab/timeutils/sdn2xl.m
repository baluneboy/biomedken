function dtmExcel=sdn2xl(sdn);

%SDN2XL - convert matlab serial date number to excel time based number
%          (Excel is 1900 based, while MATLAB is 0000 based)
%
%dtmExcel=sdn2xl(sdn);
%
%Inputs: sdn - matlab based serial date number
%
%Outputs: dtmExcel - excel based date number

% Author: Ken Hrovat
% $Id: sdn2xl.m 4160 2009-12-11 19:10:14Z khrovat $

dtmExcel=sdn-693960;