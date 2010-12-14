function [t,y] = generate_one_epoch_example(freq,durEpochSec,A,Anoise)

% EXAMPLE
% A = 5; % amplitude (uV)
% Anoise = 1; % amplitude of noise (uV)
% durEpochSec = 0.320; %that's 320msec
% freq = 9.375; %Hz (integer multiple of cycles in an epoch is 3*1/durEpochSec)
% [t,y] = generate_one_epoch_example(freq,durEpochSec,A,Anoise); figure, plot(t,y)

fs = 250;
dt = 1/fs;
t = 0:dt:durEpochSec-dt;
ySin = A*sin(2*pi*freq*t);
tmp = Anoise*normalize(randn(size(ySin)));
yNoise = tmp - mean(tmp);
y = ySin + yNoise;