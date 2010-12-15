function [H,freqBins,PSDBins,numPSDs]=hist2dspec(f,b,FLim,CLim);

%hist2dspec - 2D histogram from spectrogram matrices
%
%[H,freqBins,PSDBins,numPSDs]=hist2dspec(f,b,FLim,CLim);
%
%Inputs: f - vector of frequencies
%        b - matrix of spectrogram PSD values
%        FLim - 2-element vector of [minFreq maxFreq]
%        CLim - 2-element vector of [minPSD maxPSD], like [-12 -6]
%
%Outputs: H - histogram matrix;  H(i,j) = number of data points
%             satisfying freqBins(j) <= f < freqBins(j+1) and
%                        PSDBins(i) <= log10(PSD) < PSDBins(i+1)
%         freqBins - bin lower freq-ordinates (one for each column of H)
%         PSDBins -  bin lower PSD-ordinates (one for each row of H)
%         numPSDs - scalar number of PSDs for this b matrix

%Author: Ken Hrovat, 9/18/2001
% $Id: hist2dspec.m 4160 2009-12-11 19:10:14Z khrovat $
% see hist2d routine

% Determine NaN columns from b matrix
ind=find(~isnan(b(1,:)));

% Remove NaN columns from b matrix
bNoNaNs=b(:,ind);
numPSDs=length(ind);

% Determine parameters for 2D histogram
minFreq=FLim(1);
maxFreq=FLim(2);
minPSD=CLim(1);
maxPSD=CLim(2);
widthFreqBin=f(2)-f(1);
heightPSDBin=0.01;
numFreqBins=ceil((maxFreq-minFreq)/widthFreqBin);
numPSDBins=floor((maxPSD-minPSD)/heightPSDBin);

% Initialize 2D histogram matrix
H=zeros(numPSDBins,numFreqBins);
if isempty(ind)
   freqBins=[];
   PSDBins=[];
   numPSDs=0;
   return
end

% Calculate histogram from b matrix (NaNs removed)
for i=1:nCols(bNoNaNs);
   p=log10(bNoNaNs(:,i));
   [h,freqBins,PSDBins]=hist2d(f(:),p(:),[minFreq widthFreqBin numFreqBins],[minPSD heightPSDBin numPSDBins]);
   H=H+h;
end
