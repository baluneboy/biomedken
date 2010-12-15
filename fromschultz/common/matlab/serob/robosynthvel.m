function robosynthvel(sourcefile,targetfile)
% ROBOSYNTHVEL - Rewrites files with deviations in velocity due to loose cable on robot
%   A filtered backwards finite difference is calculated using position to replace velocity
%
%   Usage:   robosynthvel(sourcefile,targetfile)
%   Inputs:  sourcefile - string, path to file (with corrupted velocity data)
%            targetfile - string, path to output file
%
% Note: sampling rate is critical to correctly calculate the derivative - it is hardcoded to 200
% buf if this ever changes, it needs to be modified!

% AUTHOR: Roger Cheng
% $Id: robosynthvel.m 4160 2009-12-11 19:10:14Z khrovat $

%%% Parameters without inputs yet
fs = 200;
[b,a] = butter(3,10/fs); % 5 Hz lowpass

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
    synthvx = filtfilt(b,a,diff(data(:,2))/dt);
    synthvy = filtfilt(b,a,diff(data(:,3))/dt);
else % non-uniform spacing, process each chunk by itself
    chunk_starts = find(diff(d_ind))+1;
    chunk_starts = cat(1,1,chunk_starts(:),size(data,1));
    
    synthvx = [];
    synthvy = [];
    
    for k = 1:numel(chunk_starts)-1
        wk_data = data(chunk_starts(k):chunk_starts(k+1),1:3);
        dt = (wk_data(2,1)-wk_data(1,1))/fs;
        wk_data = diff(wk_data(:,2:3))./dt;
        if size(wk_data,1) > 18 % 3X filter order
            synthvx = cat(1,synthvx,filtfilt(b,a,wk_data(:,1)));
            synthvy = cat(1,synthvy,filtfilt(b,a,wk_data(:,2)));
        else
            synthvx = cat(1,synthvx,wk_data(:,1));
            synthvy = cat(1,synthvy,wk_data(:,2));
        end
    end
    warning('Data was non-uniformly sampled; velocity data may be incomplete');
end

% Replace data, discarding first sample (since using backwards finite difference)
data = data(2:end,:);
data(:,4:5) = [synthvx,synthvy];

% Write to output
robowrite(targetfile,data,hdr);


