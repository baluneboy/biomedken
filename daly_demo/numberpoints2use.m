function [T,numEpochsWario] = numberpoints2use(msecEpochWario,msecEpochWadsworth,numEpochsWadsworth)

% EXAMPLE
% msecEpochWario = 320;
% msecEpochWadsworth = 320;
% numEpochsWadsworth = 22;
% [T,numEpochsWario] = numberpoints2use(msecEpochWario,msecEpochWadsworth,numEpochsWadsworth)
% fprintf('\n%g, %g msec, %g, %g',numEpochsWadsworth,T*1e3,numEpochsWario,T)

% ptsTotal = 22;
% ptsEpoch = 4;
% ptsOverlap = 2; % = 1
% [ptsUse,numChunksOnTheLeft] = numberpoints2use(ptsTotal,ptsEpoch,ptsOverlap)
%
% ptsOnTheLeft = ptsEpoch - ptsOverlap;
% ratio = (ptsTotal-ptsOverlap) / ptsOnTheLeft;
% numChunksOnTheLeft = floor( ratio );
% ptsUse = numChunksOnTheLeft*ptsOnTheLeft + ptsOverlap; 

Tmsec = (numEpochsWadsworth+1)*(msecEpochWadsworth/2);
numEpochsWario = (Tmsec-(0.25*msecEpochWario))/(0.75*msecEpochWario);
T = Tmsec/1e3;
