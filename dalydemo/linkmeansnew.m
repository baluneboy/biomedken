function linkmeansnew(h,str)

% EXAMPLE
% str = 'move';
% y = exp(rand(100,2));
% H = boxplot(y);
% h = H(:,1);
% % set(gca,'xlim',[0 1],'ylim',[0 1]);
% % hold on;
% % hPlot = plot(x,y,'ro');
% % hText = text(0.9,0.9,'hello');
% % set(hPlot,'tag','plotline');
% linkmeansnew(h,str);

h = excisenan(h);
for i = 1:length(h)
    hMe = h(i);
    hOthers = setdiff(h,hMe);
    set(hMe,'UserData',[hMe hOthers(:)']);
    draggable(hMe,'v',[0 1],@locMotionFcn);
    set(hMe,'tag',['hg_' str]);
end

%-----------------------------
function locMotionFcn(hMoving)  % "currently-moving" handle is passed in
h = get(hMoving,'UserData');  % get the [me others] plot handles
hMe = h(1);
hOthers = h(2:end);
% hText = h(2);
yd = get(hMoving,'ydata');
newMu = mean(yd);
for i = 1:length(hOthers)
    h = hOthers(i);
    yOtherOld = get(h,'ydata');
    yOtherNew = yOtherOld - mean(yOtherOld) + newMu;
    set(h,'YData',yOtherNew);    % update the y data
end
% set(hText,'string',sprintf('%.2f',newMu))