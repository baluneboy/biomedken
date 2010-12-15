function [datamax,datamin,dremmax,dremmin] = intminmax(data,sHeader,sPlot)

% INTMINMAX calculates the minimum and maximum values for data in intervals specified by sPlot 
%
%   [data,remdata] = intminmax(data,sPlot)
%
%   Input:   data = [x y z ...]
%   Output:  data = [minx miny minz maxx maxy maxz]  (multiple rows from full sets in data)
%            remdata = [minx miny minz maxx maxy maxz] (one row from last incomplete set in data)
% Author: Eric Kelly
% April 14,2001
% $Id: intminmax.m 4160 2009-12-11 19:10:14Z khrovat $
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
dremmin =[];dremmax =[];

% create function string
if strcmp(sPlot.FunctionType,'nan')
   strMinFunction = 'nanmin';
   strMaxFunction = 'nanmax';
else
   strMinFunction = 'min';
   strMaxFunction = 'max';
end


% step through each column of data and calculate the interval minimums and maximums
for index = 1:numColumns 
   % create buffer matrix
   [temp,rem] = buffer(data(:,index),IntervalSize,num2repeat,OPT);
   
   % Initialize new data matrix 
   if index==1
      datamin = zeros(size(temp,2),numColumns);
      datamax = datamin;
   end
   
   % calculate each interval mean or nanmean
   datamin(:,index) = (feval(strMinFunction,temp))';
   datamax(:,index) = (feval(strMaxFunction,temp))';
   % calculate the remainder
   if ~isempty(rem)
      dremmin = [dremmin feval(strMinFunction,rem)];
      dremmax = [dremmax feval(strMaxFunction,rem)];
   end
end



 