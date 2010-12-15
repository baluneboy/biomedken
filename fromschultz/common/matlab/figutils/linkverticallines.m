function linkverticallines(hLines,hFig)

% LINKVERTICALLINES link xdata property of vertical lines
%
% USAGE:
% linkverticallines(hLines,hFig);
%
% INPUTS:
% hLines - vector of vertical line object handles
% hFig - handle to figure parent of vertical lines
%
% OUTPUTS:
% none
%
% EXAMPLE
% hFig = figure;
% subplot(211),h1 = line([5 5],[0 1]);
% subplot(212),h2 = line([5 5],[0 1],'color','r');
% linkverticallines([h1 h2],hFig)

% Author: Ken Hrovat, Krisanne Litinas
% $Id: linkverticallines.m 4160 2009-12-11 19:10:14Z khrovat $

h = guidata(hFig);
h.hLink = linkprop(hLines,'Xdata');
for i = 1:length(hLines), draggable(hLines(i)); end
guidata(hFig,h);