function out=pswindowgen(winchoice,nfft)

% This function is used to generate the windows.  Inputs are the numerical value
% for the window choice and the length of the window (nfft)

if winchoice==1
	out=bartlett(nfft);
elseif winchoice==2
	out=blackman(nfft);
elseif winchoice==3
	out=boxcar(nfft);
elseif winchoice==4
	out=hamming(nfft);
elseif winchoice==5
	out=hanning(nfft);
elseif winchoice==6
	out=kaiser(nfft,5);
elseif winchoice==7
	out=triang(nfft);
else
	disp('Something is wrong with window choice')
end
