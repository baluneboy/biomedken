function casUL12=top2textul(sHeader);

%top2textul - use header to generate top 2 lines of upper left text
%
%casUL12=top2textul(sHeader);
%
%Input: sHeader - structure of header info
%
%Output: casUL12 - cell array of strings for top 2 in upper left

%Author: Ken Hrovat, 3/24/2001
%$Id: top2textul.m 4160 2009-12-11 19:10:14Z khrovat $

strSensorID=strrep(sHeader.SensorID,'_','\_');
strDataType=strrep(sHeader.DataType,'_accel','');

% For MAMS data, need to remove the sensor also (e.g. ossftmf,ossraw,ossbtmf)
if ~isempty(findstr('mams',strDataType))
   strDataType = 'mams';
end
strDataType=strrep(strDataType,'_','\_');
strLocation=strrep(sHeader.SensorCoordinateSystemName,'_','\_');

fs=sHeader.SampleRate;
fc=sHeader.CutoffFreq;


% If quasi-steady data and Sensor location is not 'oss', then the data has
% been mapped, otherwise it is the sensor location.
if ~isempty(findstr('oss',sHeader.DataType)) ...
      & isempty(findstr('oss',sHeader.SensorCoordinateSystemName))
   strPreposition = ' mapped to';
   strLocation=strrep(sHeader.SensorCoordinateSystemName,'_','\_');
else
   strPreposition = 'at';
   strLocation = [' ,' sHeader.SensorCoordinateSystemComment ','];
   strLocation=strrep(sHeader.SensorCoordinateSystemComment,'_','\_');
end

if ~strcmp(sHeader.SensorCoordinateSystemName,'CM')
	strDataLoc = sprintf(':[%4.2f %4.2f %4.2f]',sHeader.SensorCoordinateSystemXYZ); 
else
   strDataLoc = '';
end

strDataInfo= sprintf('%s, %s %s %s',strDataType,strSensorID,strPreposition,strLocation);
casUL12{1}= [strDataInfo strDataLoc];

% TMF data can have sample rate of .0625, so want to show all digits
if ~isempty(sHeader.SampleRate < 1)
   casUL12{2}=sprintf('%.4f sa/sec (%.2f Hz)',fs,fc);
else
   casUL12{2}=sprintf('%.1f sa/sec (%.2f Hz)',fs,fc);
end





