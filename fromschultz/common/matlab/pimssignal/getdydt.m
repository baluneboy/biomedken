function [dydt,t] = getdydt(y,fs)
% getdydt.m - calculates dy/dt and generates t vector
% 
% INPUTS
% y - vector
% fs - sampling rate [Hz]
% 
% OUTPUTS
% dydt - vector with size(y)
% t - time vector, size(y)
% 
% EXAMPLE
% y = [4 4 4 5 6 7 7 7 7];
% fs = 1;
% [dydt,t] = getdydt(y,fs)

% Author - Krisanne Litinas
% $Id$

% Take derivitive of y
dy = [nan diff(y)];

% Get dydt
dydt = dy/(1/fs);

% Generate t vector for dydt
t = gent(dydt,fs);