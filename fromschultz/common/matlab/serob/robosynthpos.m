function robosynthpos(sourcefile,targetfile)
% ROBOSYNTHPOS - Rewrites files with bad position data using velocity
%   A trapezoidal integration is calculated using velocity to replace position
%
%   ** Important - an integral requires an initial condition - the best that can be done is to assume
%    that the FIRST positional data point (x1,y1) is correct - if this is not the case, the
%    generated positional data by definition WILL NOT BE ACCURATE **
%
%   Usage:   robosynthpos(sourcefile,targetfile)
%   Inputs:  sourcefile - string, path to file (with corrupted position data)
%            targetfile - string, path to output file
%
% Note: sampling rate is critical to correctly calculate the integral - it is hardcoded to 200
% buf if this ever changes, it needs to be modified!

% AUTHOR: Roger Cheng
% $Id: robosynthpos.m 4160 2009-12-11 19:10:14Z khrovat $

%%% Parameters without inputs yet
fs = 200;

% Read source file
[hdr,data] = roboread_hdr(sourcefile);
% Assumptions: Column 1 - index; Columns 2,3 - x,y; Columns 4,5 - vx,vy
% Final error check - files with velocity should have 8+ columns
if size(data,2) < 8
    error('Expecting at least 8 columns for safety; processing aborted');
end

% Check index for gaps
d_ind = diff(data(:,1));
gap_sizes = unique(d_ind);

if numel(gap_sizes) == 1 % uniform spacing
    if gap_sizes == 1 % Normal condition
        dt = 1/fs;
    else % Funky spacing
        dt = gap_sizes/fs;
        warning('Index increasing by %0.0f; effective sample rate is %0.2f',gap_sizes,1/dt);
    end
    synthx = cumtrapz(data(:,4))*dt+data(1,2);
    synthy = cumtrapz(data(:,5))*dt+data(1,3);
else % non-uniform spacing, abort
    error('Data was non-uniformly sampled; accurate position data cannot be determined from velocity alone');
end

% Replace data, discarding first sample (since using backwards finite difference)
data(:,2:3) = [synthx,synthy];

% Write to output
robowrite(targetfile,data,hdr);


