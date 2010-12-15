function [numGaps,iBad,gapLengths] = gapdetector(strFile,blnVerbose)

% gapdetector - find gaps in serob dat files via ind column from roboread
%
% [numGaps,iBad,gapLengths] = gapdetector(strFile);
%
% INPUTS:
% strFile - string for path to serob dat file
% blnVerbose - boolean (1 = verbose, 0 = silent)
%
% OUTPUTS:
% numGaps - scalar number of gaps detected
% iBad - vector of indices where gaps occur
% gapLengths - vector of gap lengths (in samples)
%
% EXAMPLE
% strFile = 'S:\data\upper\serob\therapist\s1331plas\eval\20071206_Thu\chase_rob_123505_ball_9.dat';
% [numGaps,iBad,gapLengths] = gapdetector(strFile);

% author: Ken Hrovat
% $Id: gapdetector.m 4160 2009-12-11 19:10:14Z khrovat $

% check input count
if nargin == 1
    blnVerbose = 0;
end

% read data
[ind,x,y,vx,vy,fx,fy,fz]=roboread(strFile);

% find gaps
diffind = diff(ind);
iBad = find(diffind > 1);
numGaps = length(iBad);
gapLengths = diffind(iBad);

% some command window text
if blnVerbose
    if numGaps>1
        fprintf('\n%d gaps in %s, n1 = %d, n2 = %d\n',numGaps,strFile,gapLengths(1),gapLengths(2))
    else
        fprintf('\n%d gaps in %s\n',numGaps,strFile)
    end
end