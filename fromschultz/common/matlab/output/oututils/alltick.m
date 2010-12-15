function axh=alltick(a,vals)

% ALLTICK - Function to set all aticks in current figure to common settings.
%
% axh=alltick(a,vals);
%
% Input: a - one character string for x or y tick (xtick or ytick)
%        vals - vector of values for ticks
%
% Output: axh - handles to all axes in current figure

% written by: Ken Hrovat on 10/30/97
% $Id: alltick.m 4160 2009-12-11 19:10:14Z khrovat $

axh=findobj('type','axes');
for i=1:length(axh)
	axes(axh(i));
	cmstr=['set(gca,''' lower(a) 'tick'',vals);'];
	eval(cmstr);
end

