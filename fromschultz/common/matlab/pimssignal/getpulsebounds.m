function pulse_bounds = getpulsebounds(y,thresh)
% getpulsebounds.m - simple function that returns pulse starts and ends for given threshhold
%
% INPUTS
% y - vector, signal with pulses in it
% thresh - threshhold, lower bound to look for pulse
% 
% OUTPUTS
% pulse_bounds - nx2 matrix, [starts ends]; n = number of pulses
% 
% EXAMPLE
% y = [2 2 2 6 6 1 2 2 8 8 8];
% pulse_bounds = getpulsebounds(y,4)

% Author - Krisanne Litinas
% $Id$

iPulse = find(y > thresh);
[starts, durs] = contig(y,iPulse);
ends = starts + durs - 1;
pulse_bounds = [starts ends]; 