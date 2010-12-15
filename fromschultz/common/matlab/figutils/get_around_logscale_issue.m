%% A troublesome "difference" matrix (log10 does not like values <= 0)
NEGLO = -1e-100; POSLO = -NEGLO;
NEGMD = -1e+000; POSMD = -NEGMD;
NEGHI = -1e+100; POSHI = -NEGHI;
m = [NEGHI NEGMD NEGLO 0 POSLO POSMD POSHI];

%% Sign matrix
s = sign(m);

%% Take log of absolute value of troublesome matrix
L = log10(abs(m));

%% Fix where zeros were (this'd be midscale)
L(iZero) = 0;

%% Reapply the sign
a = s.*L;

%% Do the image, making sure to keep zero in the middle (symmetrical CLIM arg)
imagesc(a);
colormap(shadesofredblue);
colorbar