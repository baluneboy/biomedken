function [data,sHeader] = popconvertdata (data,sHeader,sParameters,varargin)

% POPCONVERTDATA is used to perform the basic data conversions on the
% [t x y z s] data.  These operations include TMF and Interval Average filters, coordinate
% tranformations, mapping of acceleration data to other locations, adding or removing 
% bias operations and frame of reference change.
%
%          [data,header] = popconvertdata (data,header,sParameters)
%          [data,header] = popconvertdata (data,header,sParameters,sSearch)
% olddata and data are data structures containing acceleration data with the columns [t x y z ...]
% POPCONVERTDATA decides what conversions to do by comparing appropriate fields in header and sParameters.


% 
%  Author: Eric Kelly
% $Id: popconvertdata.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Check for extra inputs for use in qsmapping
if nargin==3
   sSearch=[];
elseif nargin==4
   sSearch=varargin{1};
end

%
%  DO TMF,INT AVERAGE, OR MIN/MAX Conversions
%

% Change filtersize, filterinterval from seconds to samples/sec
% if ~(strcmp(sParameters.FilterType,'no_filter'))
%    
%    filtsize = header.SampleRate*sParameters.filter.FilterSize;
%    intsize = header.SampleRate*sParameters.filter.IntervalSize;
%    
%    switch (sParameters.FilterType)
%    case 'trimmed_mean'
%       [data ,header] = popmamstmf(data,header,filtsize,intsize);   
%    case 'interval_average'
%       [data ,header] = popmamsintavg(data,header,filtsize,intsize);          
%    end
% else 
%    data = data;
%    header  = header;
% end
% 
% clear data header


%
%  DO Mapping Routines for quasi-steady data
%
if ~isempty(findstr(sHeader.DataType,'tmf'))
    if ~(strcmp(sHeader.SensorCoordinateSystemName, sParameters.sMap.Name) &...
            strcmp(sHeader.SensorCoordinateSystemComment,sParameters.sMap.Comment)); 
        [data,sHeader] = qsmapping(data,sHeader,sParameters,sSearch);
    end
end


%
%   Coordinate System Transformation
% 
% compare the Name and Time, if they are different, do transformation
if ~(strcmp(sHeader.DataCoordinateSystemName,sParameters.sCoord.Name)...
      & strcmp(sHeader.DataCoordinateSystemTime,sParameters.sCoord.Time))
     [data,sHeader] = transformcoord(data,sHeader,sParameters.sCoord);
end



