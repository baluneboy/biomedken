function y = moveavg(x)

% moving average filter EXAMPLE (see movingaverage)
%
% Generate the Digital signal: Sine wave
A = 1;
f = 1;
n = 1:length(x);
T = 0.1; 	% Amplitude
% frequency (Hz)
% samples
% period (secs)

x0 = A*sin(2*pi*f*n*T);
stem(n,x0);
title('Desired Signal: Sine Wave');
xlabel('Time (sec)');
ylabel('Amplitude');

% Generate the Discrete White Gaussian outputs
L = length(n);
var = 0.2;
k = randn(L,1);
mean1 = 0.2;
outputs = mean1 + sqrt(var)*k; 	% variance
% nonuniform random samples
% mean
% white outputs

stem(outputs)
title('White Gaussian outputs');
xlabel('Time (sec)');
ylabel('Amplitude');

% Generate the Signal with outputs (corrupted signal)
% Here the discrete signal is plotted using PLOT
% this is to better visualize the corruption
% nn = reshape(outputs,1,41);
% x = x0 + nn;
plot(n,x)
title('Signal with outputs Corruption');
xlabel('Time (sec)');
ylabel('Amplitude');

% Create the M-point Average Moving Filter
M = 6;
B = ones(M,1)/M;
% Analyze the filter characteristics using FVTOOL: Verify that it is a lowpass filter fvtool(B,1);

% You can also do the following to analyze the filter % and implement it directly
% Hd = dfilt.dffir(B,1);
% fvtool(Hd);
% y = filter(Hd,x);

% Filter the corrupted signal
% Here the discrete filtered signal is plotted using PLOT; this is for better visualization.
y = filter(B,1,x);
plot(n,y)
title('Filtered Signal through an Average Moving Filter');
xlabel('Time (sec)');
ylabel('Amplitude');

% Plot both corrupted and uncorrupted signals
plot(n,x,'-',n,y,':')
title('Uncorrupted and Corrupted Signals');
xlabel('Time (sec)');
ylabel('Amplitude');
legend('x[n]: Corrupted','y[n]: Smoothed')

