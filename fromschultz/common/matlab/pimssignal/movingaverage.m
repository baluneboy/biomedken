function yf=movingaverage(y,fs,tc)

% MOVINGAVERAGE moving average filter
%
% INPUTS:
% y - vector of values to filter
% fs - scalar sample rate (sa/sec)
% tc - scalar time constant for averaging (sec)
%
% OUTPUTS:
% yf - vector of filtered values
%
% yf = movingaverage(y,fs,tc);

% AUTHOR: Ken Hrovat
% $Id: movingaverage.m 4160 2009-12-11 19:10:14Z khrovat $

% Calculate nominal filter order (m-point moving average)
m = floor(fs*tc);

% Data must have length more than 3 times filter order
if length(y) < (3*m)
    m = floor(length(y)/3)-1;
    tc = m/fs;
    warning('data must have length more than 3 times filter order, so use order = %d (tc = %g sec)',m,tc);
end

% Filter should be at least 2pts long
if m < 2
    m = 2;
    tc = m/fs;
    warning('attempted to use less than 2 pts, so use order 2 (tc = %g sec)',tc);
end

b = ones(m,1)/m;
yf = filtfilt(b,1,y);

% Trim off filter's edges
yf(1:m)=NaN;
yf(end-m+1:end)=NaN;