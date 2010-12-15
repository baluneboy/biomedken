function H = copyaxchildren(hAxFrom,hAxTo)
% EXAMPLE
% hFigFrom = figure;
% hAxFrom = axes;
% hLineBlue = plot(humps); hold on
% hLineRed = plot(1:55,'r'); hold off
% hFigTo = figure;
% hAxTo = subplot(423);
% H = copyaxchildren(hAxFrom,hAxTo);

hChildrenFrom = allchild(hAxFrom);
H = copyobj(hChildrenFrom,hAxTo);