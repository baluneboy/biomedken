function [Clim]=calcqthclim(data,header,parameters);

% This function is used by EDITQTH to calculate thecolor limits.

%
% Author: Eric Kelly
% $Id: calcqthclim.m 4160 2009-12-11 19:10:14Z khrovat $
%

% Number of data points in an x, y, or z column
singlesize = sum(~isnan(data(:,2)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALCULATIONS FOR COLORBAR LIMITS %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate bin parameters 
low=min(min([data(:,2) data(:,3) data(:,4)]));
high=max(max([data(:,2) data(:,3) data(:,4)]));
binres = double(units([parameters.AccUnits '/' header.Units])*parameters.BinRes);
bins=[low binres ceil((high-low)/binres)];

% Calculate the values for each bin
[temp]=hist2d(data(:,2),data(:,3),bins,bins);
hxy = sparse(temp);

[temp]=hist2d(data(:,2),data(:,4),bins,bins);
hxz = sparse(temp);

[temp]=hist2d(data(:,3),data(:,4),bins,bins);
hyz = sparse(temp);

clear temp;

% Convert "hits" to percentage of time:
hxz=(hxz./singlesize)*100;
hyz=(hyz./singlesize)*100;
hxy=(hxy./singlesize)*100;

Cmin=min([min(hxz) min(hyz) min(hxy)]);
Cmax=max([max(hxz) max(hyz) max(hxy)]);
Clim=[Cmin Cmax];

