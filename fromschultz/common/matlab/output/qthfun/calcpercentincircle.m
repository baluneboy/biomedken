function [percdiff] = calcpercentincircle(r,vecmag,total,targetpercent)

% CALCPERCENTINCIRCLE calculates the difference between the percentage
% of data that falls within the circle and the target percent 

%
% Author: Eric Kelly
% $Id: calcpercentincircle.m 4160 2009-12-11 19:10:14Z khrovat $
%

perc = (sum(vecmag<r)/total)*100;
percdiff = abs(perc - targetpercent);


