function d = pimsdist(x1,y1,x2,y2)

% pimsdist - calculate distance between 2 coordinates (maybe better,
% vectorized version somewheres)
%
% d = pimsdist(x1,y1,x2,y2)
%
% INPUTS: x1,y1 - scalar coordinates of 1st pt
% 
% OUTPUTS: x2,y2 - scalar coordinates of 2nd pt
%
% EXAMPLE:
% x1 = 1; y1 = 0; x2 = 1; y2 = 1;
% theDistanceBetweenThemIs = pimsdist(x1,y1,x2,y2)

% Author: Ken Hrovat
% $Id: pimsdist.m 4160 2009-12-11 19:10:14Z khrovat $

% Get diffs
dx = x1 - x2;
dy = y1 - y2;

% Use diffs for distance calc
d = sqrt( dx.^2 + dy.^2 );