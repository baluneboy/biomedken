function showcoh

randn('state',0);
h1 = ones(1,10)/sqrt(10);
r = randn(16384,1);
x = filter(h1,1,r);
noverlap = 512;
nfft = 1024;

locPlot(x,nfft,noverlap,1)
locPlot(x,nfft,noverlap,123)
locPlot(x,nfft,noverlap,1234)

% --------------------------------------
function locPlot(x,nfft,noverlap,nshift)
figure
y = circshift(x,nshift);
mscohere(x,y,hanning(nfft),noverlap,nfft);
axis([0 1 -0.5 1.5]);
strTitle = sprintf('y = circshift(x,%d)',nshift);
title(strTitle)