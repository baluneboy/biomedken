function varargout = plotcircle(radius,center,varargin)
% PLOTCIRCLE - Draws a circle
%  Usage:   h = plotcircle(radius,center,[ optional formatting arguments ]);
%  Inputs:  radius - radius of the resulting circle (double)
%           center - [x,y] coordinates of center of circle (2-element vector)
%           Additional optional arguments can be anything valid for the MATLAB 'plot' 
%            command regarding formatting (marker size, color, etc. - see 'help plot')
%  Output:  h - (optional) handle to circle
%
%  Examples: plotcircle - draws a unit circle (radius 1, center (0,0))
%            plotcircle(5) - draws a circle of radius 5 centered at (0,0))
%            plotcircle(2,[3,5]) draws a circle of radius 2 centered at (3,5)
%            plotcircle(6,[3,5],'r','LineWidth',8) draws a red circle of radius 2 
%               centered at (3,5), with 8 point line thickness
%
% Make sure axis is square before complaining that it draws an oval...
% See also plot

% AUTHOR: Roger Cheng
% $Id: plotcircle.m 4160 2009-12-11 19:10:14Z khrovat $

% Define undefined input arguments
if nargin < 1 || isempty('radius')
    radius = 1;
end
if nargin < 2 || isempty('center')
    center = [0 0];
end

% Make the actual circle
t = 0:.01:2*pi+.01;
x = cos(t);
y = sin(t);

% Plot
h = plot(radius*x+center(1),radius*y+center(2),varargin{:});

% Determine whether to output handle
if nargout == 1
    varargout{1} = h;
end
% axis square
