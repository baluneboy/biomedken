function filtered=generalFilter(signal, fs, order)

% Applies butterworth filter given signal
%
% filtered=generalFilter(signal, fs, order)

% Compiled by Morgan Clond
% $Id: generalFilter.m 4160 2009-12-11 19:10:14Z khrovat $

if nargin == 1
    fs=200;
end

if nargin <= 2
    order=3; %default 3rd order 
end

if length(signal)<=3*order %Data must have length more than 3 times filter order
    filtered=signal;
    return
end

fc=10; %Used in calculating the cutoff frequency which must be between 0 and half the sample rate

% Low-pass filter (smooth)
[b,a]=butter(order,fc/(fs/2),'low');

filtered=filtfilt(b,a,signal);