function datatip_twins(x1,y1,x2,y2)

hFig = figure;
subplot(2,1,1);
plot(x1,y1);
subplot(2,1,2);
plot(x2,y2);

h.x1 = x1;
h.x2 = x2;
h.y1 = y1;
h.y2 = y2;
guidata(hFig,h)

hTip = datacursormode(hFig);
set(hTip,'UpdateFcn',@myupdatefcn,'SnapToDataVertex','on');
datacursormode on

% -----------------------------------------
function [txt] = myupdatefcn(obj,event_obj)
h = guidata(gcbf);
pos = get(event_obj,'Position');
x1 = h.x1(pos(1));
x2 = h.x2(pos(1));
y1 = h.y1(pos(1));
y2 = h.y2(pos(1));
txt = {['x1: ',num2str(x1) ', y1: ',num2str(y1)],['x2: ',num2str(x2) ', y2: ',num2str(y2)]};