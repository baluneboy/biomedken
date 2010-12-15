function [frequencies,mags]=pcsa(f,pxx,freq_range,topn,nbd,thresh);
% PCSA - Performs Principal Component Spectral Analysis on
%        the power spectral density (pxx) of interest.  User
%        specifies frequency range (freq_range) to be considered
%        along with the neighborhood (nbd) and threshold (thresh)
%        to be used by the peak detector algorithm (see dpeaks.m)
%
% [frequencies,mags]=pcsa(f,pxx,freq_range,topn,nbd,thresh);
%
% Inputs: f - frequency values for power spectral density
%         pxx - power spectral density
%         freq_range - freq_range to consider when finding peaks
%                      of the form [minf maxf]
%         topn - the number of top spectral components to return
%         nbd - neighborhood of frequencies used for peak detector
%         thresh - threshold used for peak detector
%
% Outputs: frequencies - peak frequencies
%          mags - peak magnitudes corresponding to frequencies
%
% Calls: dpeaks

% written by: Ken Hrovat on 7/12/95
% $Id: pcsa.m 4160 2009-12-11 19:10:14Z khrovat $
% modified on: 9/21/95 - shape outputs into columns for proper sorting


% Verify i/o argument count:

if ( (nargin ~= 6) | (nargout ~= 2) )
	help pcsa
	error('PCSA REQUIRES 6 INPUT ARGs & 2 OUTPUT ARGs')
end


% Extract subsets of f and pxx if freq_range is not [0 max(f)]:

if ( (freq_range(1)~=0) | (freq_range(2)~=max(f)) )
	disp('extracting subsets of f and PSD for peak detector')
	indf=find( f >= freq_range(1) & f <= freq_range(2) );
	f=f(indf);
	pxx=pxx(indf);
end


% Perform peak detection:

ix=dpeaks(pxx,nbd,thresh);
frequencies=f(ix);
mags=pxx(ix);

% Shape vectors into columns:

frequencies=frequencies(:);
mags=mags(:);


% Sort top n peaks: 

[sx,six]=sort(mags);
if (length(six)>=topn)
 six=flipud(six);
 six=six(1:topn);
else
 %disp(sprintf('\n'))
 %disp(sprintf('The number of peaks detected is %d',length(six)))
 six=flipud(six);
end


% Return topn principal spectral components (frequencies and mags):

frequencies=frequencies(six);
mags=mags(six);


