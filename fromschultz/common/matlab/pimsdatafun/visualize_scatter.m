function h = visualize_scatter(m,strTitle,casLabels)

% VISUALIZE_SCATTER visualize scatter
c1 = 1;
c2 = 2;
strXlabel = casLabels{c1};
strYlabel = casLabels{c2};

h.hFig = figure;
h.hAx = gca;
h.hDot = plot(m(:,c1),m(:,c2),'.');
padborder(h.hAx,10);
title(strTitle);
xlabel(strXlabel);
ylabel(strYlabel);
set(h.hDot,'markersize',18);
h.hLineLS = lsline;
set(h.hLineLS,'linestyle','--');