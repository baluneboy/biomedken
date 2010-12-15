function [x,pxx,f] = whitenoisegen(fs,N,mu,sigma,nfft)

% WHITENOISEGEN generate white noise with mu mean and sigma std dev
%
% EXAMPLE
% fs = 250;
% N = 8192; % Number of data points
% mu = 0; % mean
% sigma = 1; % standard deviation
% nfft = N/8;
% [x,pxx,f] = whitenoisegen(fs,N,mu,sigma,nfft);

% White gaussian noise sequence
x = mu + sigma*randn(N,1);
[pxx,f] = pwelch(x,nfft,nfft/2,nfft,fs,'onesided'); % uses default window, overlap & NFFT
xrms_freq = parseval(f,pxx,max(f),[0 max(f)]);
xrms_time = rms(x);
fprintf('\nParseval xRMS Check: freq = %.3f, time = %.3f\n',xrms_freq,xrms_time)