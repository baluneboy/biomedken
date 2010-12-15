function vSmooth = smoothfiltfilt(vRough,fs,n,fc)

% EXAMPLE
% fs = 200; % sample rate of vRough (in samples per second)
% fc = 5; % cutoff frequency of lowpass filter (in Hz)
% n = 9; % order of butterworth lowpass filter
% vRough = sin(2*pi*2*t) + randn(size(t))/3;
% hLineBlueRough = plot(t,vRough);
% hold on
% vSmooth = smoothfiltfilt(vRough,fs,n,fc);
% hLineRedSmooth = plot(t,vSmooth,'r'); set(hLineRedSmooth,'linewidth',2);

[b,a] = butter(n,fc/(fs/2),'low');
vSmooth = filtfilt(b,a,vRough);