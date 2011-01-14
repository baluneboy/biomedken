function [newdata,drem] = intrms(data,sHeader,sPlot)

% INTRMS calculates the root mean square for data in intervals specified by sPlot 
%
%   [data,remdata] = intrms(data,sPlot)
%
% Author: Eric Kelly
% April 14,2001
% $Id: intrms.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Get filtersize and filterinterval in samples
IntervalSize = sPlot.IntervalSize*sHeader.SampleRate;
IntervalStep = sPlot.IntervalStep*sHeader.SampleRate;

% calculate the number of samples repeated in next interval 
num2repeat = IntervalSize-IntervalStep;
if (num2repeat==0)
  OPT = [];
else 
   OPT = 'nodelay';
end

% Determine how many columns of data need converting
numColumns = size(data,2);
drem =[];

% create function string
if strcmp(sPlot.FunctionType,'nan')
   strFunction = 'nanrms';
else
   strFunction = 'rms';
end

% step through each column of data and calculate the interval means
for index = 1:numColumns 
   % create buffer matrix
   [temp,rem] = buffer(data(:,index),IntervalSize,num2repeat,OPT);
   
   % Initialize new data matrix 
   if index==1
      newdata = zeros(size(temp,2),numColumns);
   end
   
   % calculate each interval mean or nanmean
   newdata(:,index) = (feval(strFunction,temp))';
   % calculate the remainder
   if ~isempty(rem)
      drem = [drem feval(strFunction,rem)];
   end
end


 
 