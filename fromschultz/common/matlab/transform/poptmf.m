function [newdata,drem] = poptmf(data,sHeader,sPlot)

% POPTMF calculates the trimmed mean filtered data for a structure s, 
% with four vector components: t, x, y, and z. Filtersize and filterinterval
% are in number of samples. stmf is a structure with four vector components:
% t, x, y, and z.  
%
%  [tmfdata,tmfheader] = popmamstmf(data,header,sPlot);
% 


%
% Author: Eric Kelly
% April 14,2001
% $Id: poptmf.m 4160 2009-12-11 19:10:14Z khrovat $
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

% step through each column of data and calculate the interval trimmed mean
for index = 1:numColumns 
  % create buffer matrix
  [temp,rem] = buffer(data(:,index),IntervalSize,num2repeat,OPT);
  
   % Initialize new data matrix 
  if index==1
  newdata = zeros(size(temp,2),numColumns);
  end
  
  % calculate each interval mean or nanmean
  newdata(:,index) = poptrimmean(temp);
  
  % CURRENTLY RESTRICITING TMF TO NOT ALLOW CALCULATION OF INCOMPLETE SETS
  % calculate the remainder
  %drem = [drem poptrimmean(rem)];
end

% CURRENTLY RESTRICITING TMF TO NOT ALLOW CALCULATION OF INCOMPLETE SETS
drem=[];