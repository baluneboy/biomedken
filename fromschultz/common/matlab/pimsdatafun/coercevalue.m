function [actualTime,actualSamples] = coercevalue(desiredTime,fs)

% COERCEVALUE integer number of samples dictates time span so coerce to nearest value
%
% EXAMPLE
% fs = 250;
% desiredTime = 83e-3;
% [actualTime,actualSamples] = coercevalue(desiredTime,fs)

% Get (possibly non-integer) number of samples
desiredSamples = fs * desiredTime;

% Round to nearest integer
actualSamples = round(desiredSamples);

% Compute actual time span from rounded number of samples
actualTime = actualSamples/fs;



