function [cm] = tempgetcmdata(header)

% This function is temporary until the rates and angles data can be retrieved.
% It loads the appropriate rates and angles.  These rates and angles are already
% matched up to the acceleration data time stamps, so there is no time column.


%
% Author: Eric Kelly
% $Id: tempgetcmdata.m 4160 2009-12-11 19:10:14Z khrovat $
%

if strcmp(header.DataType,'mams-raw')
   load('rawcmdata')
else
   load('tmfcmdata')
end

cm = reshape(cm(:,1:3)',1,3,size(cm,1));


