function [data,sHeader,TScaleFactor,strNewTimeUnits,gScaleFactor]=convertunits(data,sHeader,sParameters);

%  This function is used by POP to convert acceleration data to the desired units,
%  indicated by sParameters.GUnits, and it returns a scale factor and string for time.  
%  If header.[G?]Units does not exist, it is assumed the data is in 'g'.
%
%  [data,sHeader,TScaleFactor,strNewTimeUnits,gScaleFactor] = convertunits(data,sHeader,sParameters)
%
%
%  Input:
%   data            - acceleration data [t x y z ...]
%   sHeader         - structure includes fields GUnits and TUnits, if not present
%                     default units are 'g' and 'seconds' respectively
%   sParameters     - structure includes fields GUnits and TUnits (required)
%
%  Output:
%   data            - data with acceleration data in correct units, time units the same
%   sHeader         - structure fields updated with new units for acceleration
%   TScaleFactor    - scale factor for time conversion
%   strNewTimeUnits - String containing the new time units

% 
%  Author: Eric Kelly
% $Id: convertunits.m 4160 2009-12-11 19:10:14Z khrovat $
%


% check for presense of GUnits field, default is 'g' if not present
if ~isfield(sHeader,'GUnits')
    sHeader.GUnits = 'g';
end
if ~isfield(sParameters,'GUnits')
    sParameters.GUnits = 'g';
    
 end
 
% check for presense of TUnits field, default is 'seconds' if not present
if ~isfield(sHeader,'TUnits')
   sHeader.TUnits = 'seconds';
end
if ~isfield(sParameters,'TUnits')
   sParameters.TUnits = 'seconds';
end


 
cUnits = sHeader.GUnits;


% check for the 'auto' option
if strcmp(sParameters.GUnits,'auto')
    gmin = min(min(data));
    gmax = max(max(data));
    glim = max([abs(gmin) abs(gmax)]);
    
    % convert to 'g' for comparison
    glim = glim*getsf(cUnits,'g');
    
    % choose appropriate units
    if (glim<5e-4)
        dUnits = 'microg'
    elseif (glim<5e-1)
        dUnits = 'millig'
    else
        dUnits ='g'
    end
else
    dUnits = sParameters.GUnits;
end

% convert the data
if ~strcmp(cUnits,dUnits)
   [gScaleFactor,pUnits]=getsf(cUnits,dUnits);
   data = gScaleFactor*data;
   sHeader.GUnits = pUnits;
else
   gScaleFactor = 1;
end


% find the time units conversion factor and output
TScaleFactor = getsf(sHeader.TUnits,sParameters.TUnits);
strNewTimeUnits = sParameters.TUnits;
