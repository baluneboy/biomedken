function yf=dfiltfilt(Hd,y)
% DFILTFILT zero-phase forward and reverse digital filtering using dfilt structure (Hd)
yflip=filter(Hd,flipud(y(:)));
yf=filter(Hd,flipud(yflip));
yf=reshape(yf,nRows(y),nCols(y));