function [indLeadingEdges,durations] = getleadingedgesdurations(evt,thresh)

% GETLEADINGEDGESDURATIONS get plateaus (top of event marker pulses) for finding leading edges and durations
%
% USAGE:
% [indLeadingEdges,durations] = getleadingedgesdurations(evt,thresh);
%
% INPUTS:
% evt - vector of data to be searched for leading edge/durations
% thresh - scalar threshold for leading edge
%
% OUTPUTS:
% indLeadingEdges - Nx1 vector of leading edge indices; where N is number of pulses detected
% durations - Nx1 vector of plateau durations (in samples)
%
% EXAMPLE:
% evt = [ 0 0.2 0.8 1 1 1 0.9 0.1 0 0 0 1 1 1 0 0 1 1 0 0 1 1 1 1 ];
% thresh = 0.5;
% [indLeadingEdges,durations] = getleadingedgesdurations(evt,thresh);

% Author: Ken Hrovat
% $Id: getleadingedgesdurations.m 4160 2009-12-11 19:10:14Z khrovat $

% Some error checking
if ~isvector(evt) || ~isscalar(thresh)
    error('daly:pimssignal:badInputType','for %s, 1st argument must be a vector and 2nd must be scalar',mfilename)
end

% Get plateaus (tops of pulses)
iTop = find(evt>thresh);

% Get leading edges (leadingEdges) and widths (durations) of pulses
[indLeadingEdges,durations] = contig(1:length(evt),iTop);