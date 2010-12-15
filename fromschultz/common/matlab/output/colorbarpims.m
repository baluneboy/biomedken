function handle=colorbarpims(loc)

% This function is used to put the PIMS-type colorbar on a plot.  For the PIMS
% colorbar, there are no xticks, and the font is in times.

% The call to the main colorbar program
	if nargin==0
		handle=colorbarold;
	elseif nargin==1
		handle=colorbarold(loc);
	else
		disp('Somehow, an invalid number of input args got to COLORBARPIMS')
	end
	
% The fix-ups
	set(handle,'fontname','times');
	set(handle,'xtick',[]);
	set(handle','tickdir','in');
	set(handle,'tag','colorbarpims'); % ADDED BY HROVAT ON 12/17/97
	set(gcf,'nextplot','add')
		


% $Id: colorbarpims.m 4160 2009-12-11 19:10:14Z khrovat $
