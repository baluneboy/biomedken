function [startOneState, durOneState] = contig_statespecific(v,intStateOfInterest)
% CONTIG_STATESPECIFIC find contiguous chunks of vector of a specific integer value 
% 
% [startOneState, durOneState] = contig(v,intStateOfInterest);
% 
% INPUTS
% v - vector
% intStateOfInterest - specific integer (state) to find contiguous chunks
% 
% OUTPUTS
% startOneState - starting indices of chunks of interest
% durOneState - duration of contiguous chunks

% Author:  Krisanne Litinas 

indOfInterest = find(v == intStateOfInterest);
[startOneState,durOneState] = contig(v,indOfInterest);
