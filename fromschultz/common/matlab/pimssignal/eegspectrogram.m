function [b,f,ch]=eegspectrogram(v,fs);
% EEGSPECTROGRAM spectrogram of EEG data, v, at sample rate of fs
%
% INPUTS:
% v - vector of EEG readings (uV)
% fs - scalar sample rate (sa/s)
%
% OUTPUTS:
% b - matrix of spectral magnitudes (uV^2/Hz)
% f - vector of frequencies (Hz)
% ch - vector of channel (#)
%
% EXAMPLE:
% fs=1000; t=0:1/fs:2.047;
% x=cos(2*pi*20*t)'; % 20 Hz plus noise
% x=x-mean(x);
% v=repmat(x(:),1,64)+0.1*randn(nRows(x),64); % fake matrix of EEG values
% Nfft=256; w=Nfft; No=Nfft/2;
% eegspectrogram(v,fs); %%% OR [b,f,ch]=eegspectrogram(v,fs); %%%

% AUTHOR: Ken Hrovat
% $Id: eegspectrogram.m 4160 2009-12-11 19:10:14Z khrovat $

% Check input dimensions
Nchannels=nCols(v);
N=nRows(v);
if N==1
    error('Input has only one row (only one data point?).')
elseif Nchannels~=64
    warning(sprintf('*** Expecting 64 channels, but have %d-column input ***',Nchannels));
end

No=0;
Nfft=N;
w=Nfft;
[pvv,f]=pwelch(v(:,1),w,No,Nfft,fs);
b=[pvv(:) NaN*ones(length(pvv),1)];
for i=2:Nchannels
    [pvv,f]=pwelch(v(:,i),w,No,Nfft,fs);
    b(:,i)=pvv(:);
end
ch=1:Nchannels;

% Plot spectrogram (if no output args requested)
if nargout==0
    hFig= figure(...
        'PaperOrientation','landscape',...
        'PaperPosition',[0.25 0.25 10.5 8],...
        'PaperSize',[11 8.5]);
    set(hFig,'pos',[0 33 1024 673]);
    imagesc(ch,f,log10(abs(b)))
    axis xy
    colormap(jet)
    xlabel('Channel #')
    ylabel('Frequency (Hz)')
    title(sprintf('%d-Channel EEG Spectrogram',Nchannels))
    axis([1 64 0 200])
    set(gca,'xtick',1:Nchannels)
    xtl=cellstr(get(gca,'xticklabel'));
    [xtl{1:2:end}]=deal('');
    set(gca,'xticklabel',xtl);
    hcb=colorbar('peer',...
        gca,'EastOutside',...
        'Box','on');
    hy=get(hcb,'ylabel');
    set(hy,'str','log_{10}(\muV^2/Hz)')
end
