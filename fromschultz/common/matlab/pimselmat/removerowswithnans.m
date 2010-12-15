function mm = removerowswithnans(m)
% EXAMPLE
% m = [1 5;2 6; 3 NaN; 4 8];
% mm = removerowswithnans(m)

% Author - Krisanne Litinas
% $Id$

mm = m(~any(isnan(m),2),:);