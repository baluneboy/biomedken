function [x3,y3,pct] = commonareacurve(x1,y1,x2,y2)

% find curve, y3, which has area common to y1 and y2; also, returns
% percentage area, that is, pct = 100*(area_of_y3/area_of_y1)
%
% INPUTS:
% x1,y1 - vectors of x and y values for curve 1
% x2,y2 - vectors of x and y values for curve 2
%
% OUTPUTS:
% x3,y3 - vectors of x and y values for "common area curve", curve 3
%
% %EXAMPLE
% x1 = 0:0.01:2*pi;
% y1 = sin(x1); % baseline curve
% w = triang(floor(length(x1)/2))';
% z = -0.5*ones(1,length(x1)-length(w));
% y2 = [w z]; ; % curve compared to baseline
% x2 = x1; % for now
% [x3,y3,pct] = commonareacurve(x1,y1,x2,y2);
% stem(x3,y3), hold on
% hr = plot(x1,y1,'r'); hg=plot(x2,y2,'g'); set([hr hg],'linewidth',3);
% title({'RED = curve 1','GRN = curve 2','BLU = common area for curve 3'})
% hold off

% TODO:
% - accommodate 2 different sample rates in x1 & x2 (need to resample for this)
% - check for common domain in x1 and x2 otherwise extend range as union set

% Author: Ken Hrovat
% $Id: commonareacurve.m 4160 2009-12-11 19:10:14Z khrovat $

% verify inputs are vectors
if min(size(x1)) ~= 1 || min(size(x2)) ~= 1 || min(size(y1)) ~= 1 || min(size(y2)) ~= 1
    error('need vector inputs')
end

% verify domain
if ~all(x1 == x2)
    error('no resampling or "domain-union" yet')
end

% curve with lesser magnitude and signage
y3 = lesserabs(y1,y2);

% TODO: common domain
x3 = x1;

% areas
a1 = trapz(x1,y1);
a3 = trapz(x3,y3);
pct = 100*a3/a1;