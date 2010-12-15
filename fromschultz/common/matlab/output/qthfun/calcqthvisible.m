function [visperc,cMessage]=calcqthvisible(data,parameters);

% This function is used by EDITQTH to calculate the percent visible data and color limits.

%
% Author: Eric Kelly
% $Id: calcqthvisible.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Number of data points in an x, y, or z column
ind = find(~isnan(data(:,2)));
singlesize = length(ind);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALCULATIONS FOR PERCENT VISIBLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the limits for hist2d, making two bins encompassing the visible area
xbin = [parameters.XLim(1) (parameters.XLim(2)-parameters.XLim(1)) 1];
ybin = [parameters.YLim(1) (parameters.YLim(2)-parameters.YLim(1)) 1];
zbin = [parameters.ZLim(1) (parameters.ZLim(2)-parameters.ZLim(1)) 1];

% Calculate the number of points within the bound in each plane
[xysize]=hist2d(data(ind,2),data(ind,3),xbin,ybin);
[xzsize]=hist2d(data(ind,2),data(ind,4),xbin,zbin);
[yzsize]=hist2d(data(ind,3),data(ind,4),ybin,zbin);

% HIST2D will include extra bins for values that match the upper bounds, i.e. when bin edges are set to match
% the maximum value. This is adjusted for by summing all the bins.
xysize = sum(sum(xysize));
xzsize = sum(sum(xzsize));
yzsize = sum(sum(yzsize));

% Calculate the percentages of visible data points
xyperc = (xysize/singlesize)*100;
xzperc = (xzsize/singlesize)*100;
yzperc = (yzsize/singlesize)*100;

% Array of visible percent
visperc = [xyperc xzperc yzperc];

% Formulate String for appending to list box
% cClipMessage = cellstr(sprintf('XY-Plane: %.2f%%\nXZ-Plane: %.2f%%\nYZ-Plane: %.2f %%',xyperc,xzperc,yzperc));
cMessage{1} = sprintf('XY-Plane: %.2f%%',xyperc);
cMessage{2} = sprintf('XZ-Plane: %.2f%%',xzperc);
cMessage{3} = sprintf('YZ-Plane: %.2f%%',yzperc);