function [sdnSnapped,indBmap]=batsnaptime(sdnInput,sdnPlotTimes,gridMin,gridMax,gridStep);

%batsnaptime - coerce input serial date number times to grid times.
%
%[sdnSnapped,indBmap]=batsnaptime(sdnInput,gridMin,gridMax,gridStep);
%
%Input: sdnInput - vector of serial date numbers
%       sdnPlotTimes - vector of serial date numbers for plot grid
%       gridMin,gridMax - scalars for serial date numbers for plot begin and end
%       gridStep - scalar time step for plot grid (i.e. dTdays for spectrograms)
%
%Output: sdnSnapped - vector of serial date numbers snapped to grid
%        indBmap - vector of indices that indicate which columns of B that snapped version
%                  of input times indicate are contributed into for this data set

%written by: Ken Hrovat on 6/30/2001
% $Id: batsnaptime.m 4160 2009-12-11 19:10:14Z khrovat $

% Snap sdnInput to grid
sdnSnapped=snap2grid(sdnInput,gridMin,gridStep,gridMax,0);

% Verify that 2 of input times did not snap to same grid value (within 1 millisecond)
diffSnap=diff(sdnSnapped);
if ( abs(min(diffSnap)-gridStep) > (1e-3/86400) )
   error('two or more input times snapped to same grid value')
end

% Match vectors of grid-snapped and ideal plot times
[blnBmap,bln]=matchvec(sdnPlotTimes,sdnSnapped,gridStep/2);

% Find indices that map b to appropriate columns of B
indBmap=find(blnBmap);