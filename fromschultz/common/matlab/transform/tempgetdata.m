function [rates,raheader] = tempgetdata(header)

% This function is temporary until the rates and angles data can be retrieved.
% It loads the appropriate rates and angles.  These rates and angles are already
% matched up to the acceleration data time stamps, so there is no time column.


%
% Author: Eric Kelly
% $Id: tempgetdata.m 4160 2009-12-11 19:10:14Z khrovat $
%

if strcmp(header.DataType,'mams-raw')
   load('rawratesdata')
else
   load('tmfratesdata')
end

% Assign correct parameters to the output structure
rates = reshape(radata(:,2:7)',1,6,size(radata,1));
raheader = header;

