function [t,data,sHeader,mindata] = popintervalops (t,data,sHeader,sPlot)

% POPINTERVALOPS is used to choose and perform tmf and interval minmax,rss, and average operations.
%
%          [t,data,sHeader] = popintervalops (t,data,sHeader,sPlot)

% 
%  Author: Eric Kelly
% $Id: popintervalops.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Initialize second data set for minmax option, data = max, mindata = min;
mindata = [];
remmin =[];
trem =[];

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
        
% calculate time vector
[temp,rem] = buffer(t,IntervalSize,num2repeat,OPT);
switch(sPlot.TimeMark)
case 'start'
   t =temp(1,:)';
   if ~isempty(rem)
      trem = rem(1);
   end
case 'center'
   t = ((temp(1,:)+temp(IntervalSize,:))/2)';
   if ~isempty(rem)
      trem =((rem(1)+rem(end))/2);
   end
end
clear temp;

switch(sPlot.IntervalFunc)
case {'average'}
   [data,rem] = intaverage(data,sHeader,sPlot);
case {'minmax'}
   % data=max, mindata=min
   [data,mindata,rem,remmin] = intminmax(data,sHeader,sPlot);
case {'rms'}
   [data,rem] = intrms(data,sHeader,sPlot);
case {'tmf'}
   [data,rem] = poptmf(data,sHeader,sPlot);
end

% combine data and rem if include last incomplete sets is on
if strcmp(sPlot.ResidualPts,'keep') & ~strcmp(sPlot.IntervalFunc,'tmf') % Currently no rem calc for tmf
   data = [data;rem];
   t = [t;trem];
   mindata = [mindata;remmin];
end

% set start and end times.
sHeader.SampleRate = 1/(IntervalStep/sHeader.SampleRate);


