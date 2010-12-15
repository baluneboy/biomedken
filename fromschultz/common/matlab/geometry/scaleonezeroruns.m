function y = scaleonezeroruns(x,s)

% scaleonezeroruns - "inflate" input vector run lengths like the imresize
%                    function in image processing toolbox with doubles
%                    instead of uint8s
%
% INPUTS:
% x - vector of zeros/ones
% s - scalar for "inflation" scale factor
%
% OUTPUTS:
% y - vector of input scaled by s
%
% EXAMPLE:
% original_vector = [ 0 1 0 1 ]
% scale_factor = 2
% scaled_vector = scaleonezeroruns(original_vector,scale_factor)

% Author: Ken Hrovat
% $Id: scaleonezeroruns.m 4160 2009-12-11 19:10:14Z khrovat $

% Verify proper input dims
if ~isvector(x)
    error('daly:badInput','first input arg must be row or column vector')
end

% Verify input is just zeros and ones
if ~isequal(unique(x(:)),[0 1]')
    error('daly:badInput','first input arg must be all zeros and ones and at least one of each')
end

% Generate all zeros of type uint8 (for imresize below)
ux = zeros(size(x),'uint8');

% Set ones at desired indexes
ux(find(x)) = 1; % still have unit8s here

% Scale via image processing technique
uy = imresize(ux,s); % still uint8s

% Convert uint8s back to doubles with proper shape for vector output
if isrow(x)
    y = double(uy(1,:));
else
    y = double(uy(:,1));
end