function [t,y] = generate_one_trial_example(freq,durEpochSec,A,Anoise,numEpochs)

% EXAMPLE
% A = 5; % amplitude (uV)
% Anoise = 1; % amplitude of noise (uV)
% durEpochSec = 0.320; %that's 320msec
% freq = 9.375; %Hz (integer multiple of cycles in an epoch is 3*1/durEpochSec)
% numEpochs = 4.5; %remember 50% overlap (160msec for Wadsworth)
% [t,y] = generate_one_trial_example(freq,durEpochSec,A,Anoise,numEpochs);figure, plot(t,y)

durTrialSec = durEpochSec*numEpochs;
[t,y] = generate_one_epoch_example(freq,durTrialSec,A,Anoise);