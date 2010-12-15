function [fcent,grms,fiss,giss]=otofrompsd(f,b,fc);

% otofrompsd - compute otogram from PSD or b matrix of PSDs (fancy indexing)
%
%[fcent,grms,franges,giss]=otofrompsd(f,b,fc);
%
% Inputs: f - vector of frequencies for PSD matrix, b (evenly spaced at deltaf)
%         b - F-by-T matrix of PSD values (like that for a spectrogram)
%         fc - scalar cutoff frequency (if not empty, then put NaN for f > fc)
%
%Outputs: fcent - vector of OTO center frequencies
%         grms - B-by-T otogram matrix of RMS values for OTO bands
%         franges - stairstep vector of OTO lowerupper frequencies
%         giss - vector of ISS requirements gRMS levels 

%Author: Ken Hrovat, 4/5/2001
%$Id: otofrompsd.m 4160 2009-12-11 19:10:14Z khrovat $

% Lookup table of OTO frequency bands
moto=otoissreq;
franges=moto(:,[1 3]);
fcent=moto(:,2);

% Use Parseval's theorem to calculate RMS values
grms=parseval(f,b,fc,franges);

% Repeat shaping of frequency and grms vectors for stairstep plots
franges=franges';
fiss=franges(:);
giss=moto(:,end)';
giss=repmat(giss,2,1);
giss=giss(:);
