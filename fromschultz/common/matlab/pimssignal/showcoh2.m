function [cohmat,cohmatn,F] = showcoh2(lag,noiseamp)

% [cohmat,cohmat_noisy,F] = showcoh2(lag, noise_amp);
% lag is in samples (1/1024 of a second)
% noise amplitude is what the additive noise is scaled by
% (the 10 Hz wave has amplitude 1, & the 37 Hz has amplitude 0.2)
% The coherence will be shown for a lag of 0 to 2*lag samples.
%
% For example, showcoh2(100, .02) will lag one signal by 100 samples, and
% then show the resulting coherence when the lag is corrected by 0 to 200
% samples; at lag == 100 is when the two signals should line up perfectly
% (max coherence). It will show the original signal, as well as the same
% signal with noise added.

noverlap = 512;
nfft = 1024;
fs = 1024;

% randn('state',0);

t = 0:1/fs:20+(fs/lag); %t = 0:1/1024:20+(fs/lag);
r = sin(2*pi*10*t)+.2*sin(2*pi*37*t);
r_2 = sin(2*pi*9*t)+.25*sin(2*pi*37*t);
% r = sin(2*pi*37*t);
% r = randn(16384+lag,1);

sig1 = r(lag+1:16384+lag);
sig2 = r_2(1:16384);

% Add noise to signal
sig1n = sig1+noiseamp.*randn(size(sig1));
sig2n = sig2+noiseamp.*randn(size(sig2));

[b,a] = butter(5,60/512,'low');
sig1 = filtfilt(b,a,sig1);
sig2 = filtfilt(b,a,sig2);
sig1n = filtfilt(b,a,sig1n);
sig2n = filtfilt(b,a,sig2n);

nsamp = floor((16384-lag)/fs)*fs;
figure;
subplot(2,1,1), plot(t(1:1024),sig1(1:1024),t(1:1024),sig2(1:1024));
ylabel('Volts');
xlabel('Time (sec)');
title('Filtered Original Signal')
subplot(2,1,2), plot(t(1:1024),sig1n(1:1024),t(1:1024),sig2n(1:1024));
ylabel('Volts');
xlabel('Time (sec)');
title('Filtered Noisy Signal')


figure;
% Standard coherence
cohmat = NaN*ones(floor(fs/2)+1,lag*2+1);
sig1 = sig1(1:nsamp);
for k = 0:lag*2
    sig2_tmp = circshift(sig2(:),-k);
    sig2_tmp = sig2_tmp(1:nsamp);
    [Cxy,F] = mscohere(sig1(:),sig2_tmp(:),hanning(nfft),noverlap,nfft,fs);
    cohmat(:,k+1) = Cxy;
end
subplot(2,1,1), imagesc(cohmat); axis xy
xlim([0,2*lag]);
ylim([0,512]);
xlabel('Lag (samples)');
ylabel('Frequency (Hz)');
title('Coherence - Original (2D)');
colorbar;

% subplot(2,2,3), mesh(cohmat);
% xlim([0,2*lag]);
% ylim([0,512]);
% xlabel('Lag (samples)');
% ylabel('Frequency (Hz)');
% title('Coherence - Original (3D)')

% Noisy coherence
cohmatn = NaN*ones(floor(fs/2)+1,lag*2+1);
sig1n = sig1n(1:nsamp);
for k = 0:lag*2
    sig2_tmp = circshift(sig2n(:),-k);
    sig2_tmp = sig2_tmp(1:nsamp);
    [Cxy,F] = mscohere(sig1n(:),sig2_tmp(:),hanning(nfft),noverlap,nfft,fs);
    cohmatn(:,k+1) = Cxy;
end

subplot(2,1,2), imagesc(cohmatn); axis xy
xlim([0,2*lag]);
ylim([0,512]);
xlabel('Lag (samples)');
ylabel('Frequency (Hz)');
title('Coherence - Noisy (2D)')
colorbar;

% subplot(2,2,4), mesh(cohmatn);
% xlim([0,2*lag]);
% ylim([0,512]);
% xlabel('Lag (samples)');
% ylabel('Frequency (Hz)');
% title('Coherence - Noisy (3D)')