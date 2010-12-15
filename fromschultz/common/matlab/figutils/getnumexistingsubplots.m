function numExistPlots = getnumexistingsubplots(H)
% getnumexistingsubplots.m - find number of already-populated subplots for given figure
% 
% INPUTS
% H - figure
% 
% OUTPUTS
% numExtingPlots - number of populated plots
% 
% EXAMPLE
% H = figure;
% hSub1 = subplot(511);
% plot(humps);
% hSub2 = subplot(512);
% plot(1:13,'r')
% numExistingPlots = getnumexistingsubplots(H)

% Author:  Krisanne Litinas
% $Id$

hExisting = findobj(H,'type','axes');
hLegExisting = findobj(H,'tag','legend');
existingPlots = setdiff(hExisting,hLegExisting);
numExistPlots = length(existingPlots);