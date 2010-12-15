function [B,indBmap,sdnPlotTimes,gridMin,gridMax,sdnPreviousEnd,numAx]=binitialize(sdnPlotBegin,sdnPlotEnd,gridStep,strFirstFile,iKeepFreq);

%binitialize - initialize B matrix for color spectrogram
%
%[B,indBmap,sdnPlotTimes,gridMin,gridMax,sdnPreviousEnd,numAx]=binitialize(sdnPlotBegin,sdnPlotEnd,gridStep,strFirstFile,iKeepFreq);
%
%Input: sdnPlotBegin,sdnPlotEnd - scalars for serial date numbers for plot begin and end
%       gridStep - scalar time step for plot grid (i.e. dTdays for spectrograms)
%       strFirstFile - string for first overall filename for this plot
%       iKeepFreq - vector of indices of frequency (rows) to keep
%
%Output: B - matrix for color spectrogram initialized with first file's contribution included
%        indBmap - vector of indices that indicate which columns of B were contributed into by 1st file
%        sdnPlotTimes - vector of serial date numbers for plot (NaNs where input times were not on grid)
%        gridMin,gridMax - scalar serial date numbers for plot's time grid
%        sdnPreviousEnd - scalar serial date number for snapped end time
%        numAx - scalar number of axes (usually 1 for sum, but maybe 3 for XYZ)

%modified by Hrovat on 1/2/02 to add XYZ (3) axes case
%written by: Ken Hrovat on 7/1/2001
% $Id: binitialize.m 4160 2009-12-11 19:10:14Z khrovat $

% Load first file's b matrix and t vector
load(strFirstFile)
numAx=size(b,3);

% Verify t(1)>=(sdnPlotBegin-gridStep)
if t(1)<(sdnPlotBegin-gridStep)
   error('first time in first file for this plot is less than desired begin time minus a time step')
end

% Calculate number of steps back from t(1) to sdnPlotBegin
numStepsBack=ceil((t(1)-sdnPlotBegin)/gridStep);

% Calculate gridMin
gridMin=t(1)-(numStepsBack*gridStep);

% Calculate number of total steps in plot's time grid
numStepsTotal=ceil((sdnPlotEnd-gridMin)/gridStep);

% Calculate gridMax
gridMax=gridMin+(numStepsTotal*gridStep);

% Calculate plot's time grid
sdnPlotTimes=gridMin:gridStep:gridMax;

% Initialize B matrix
if numAx==1
   B=NaN*ones(length(iKeepFreq),length(sdnPlotTimes));
elseif numAx==3
   B=NaN*ones(length(iKeepFreq),length(sdnPlotTimes),3);
else
   error('unaccounted for number of dimensions for b')
end

% For first file, snap time to grid and incorporate it's contribution to B
[sdnSnapped,indBmap]=batsnaptime(t,sdnPlotTimes,gridMin,gridMax,gridStep);
for iAx=1:numAx
   B(:,indBmap,iAx)=b(iKeepFreq,:,iAx);
end

% Get last time of first file's contribution
sdnPreviousEnd=sdnSnapped(end);