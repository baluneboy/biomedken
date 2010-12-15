function axh=allaxis(ax)

% ALLAXIS - Function to set all axes in current figure to common settings.
%
% axh=allaxis(ax);
%
% Input: ax - 4 element vector for [xmin xmax ymin ymax]
%
% Output: axh - handles to all axes in current figure

% written by: Ken Hrovat on 11/22/96
% $Id: allaxis.m 4160 2009-12-11 19:10:14Z khrovat $

axh=findobj('type','axes');
for i=1:length(axh)
	axes(axh(i));
	axis(ax);
end

