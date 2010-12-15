function [scale,ytick,yticklabels]=detytick(ylim,numticks)

% DETYTICK - Function to determine "nice" y-limits, -ticks, -ticklabels and
%           scale for circumventing matlab's built-in "x10.." on top of
%           plots.  If ymin in old y-limits is negative, then return new
%           y-limits that are symmetric about zero.
%
% [scale,ytick,yticklabels]= detytick(ylim,numticks);
%
% Inputs: ylim - 2 element vector containing [ymin ymax]
%         numticks - scalar number of tick marks
%
% Outputs: scale - scalar for scaling data and thus circumventing matlab's
%                  built-in "x10.." on top of plots
%          ytick - 6 or 11 element vector of "nice" yticks
%          yticklabels - 6 or 11 row string matrix for "nice" y tick labels

% written by: Ken Hrovat on 12/28/95
% $Id: detytick.m 4160 2009-12-11 19:10:14Z khrovat $

% 1. Verify i/o count
% 2. Extent = max(abs(ylim))
% 3. Use int10.m to extract mantissa and exponent of extent
% 4. Use scienote.m to convert to scientific notation
% 5. Calculate scale
% 6. Use number of ticks to determine dtick
% 7. Generate yticks and yticklabels


% Initialize
	yticklabels=[];

% 1. Verify i/o count

if ( (nargin~=2) | (nargout~=3) )
	error('DETYTICK: REQUIRES 4 OUTPUT AND 1 INPUT ARGUMENT')
end


% 2. Extent = max(abs(ylim))

extent = max(abs(ylim));


% 3. Use int10.m to extract mantissa and exponent of extent

[oldman,oldexp]=int10(extent); 


% 4. Use scienote.m to convert to scientific notation

[newman,newexp]=scienote(oldman,oldexp);


% 5. Calculate scale

scale=1/10^newexp;


% 6. Use number of ticks to determine dtick

dtick=(max(ylim)-min(ylim))/numticks;


% 7. Generate yticks and yticklabels

ytick=min(ylim)*scale:dtick*scale:max(ylim)*scale;
for yt=ytick
	yticklabels=str2mat(yticklabels,sprintf('%04.2f',yt));
end

yticklabels=yticklabels(2:size(yticklabels,1),:);


