function linkmeans(hLine,hPlot,hText)

% EXAMPLE
% hLine = line([0 1],0.5*[1 1]);
% y = [0.2:0.1:0.8]; x = 0.5*ones(size(y));
% set(hLine,'tag','dashedline');
% set(gca,'xlim',[0 1],'ylim',[0 1]);
% hold on;
% hPlot = plot(x,y,'ro');
% hText = text(0.9,0.9,'hello');
% set(hPlot,'tag','plotline');
% linkmeans(hLine,hPlot,hText);

set(hLine,'UserData',[hPlot hText]);
set(hPlot,'UserData',[hLine hText]);
draggable(hLine,'v',[0 1],@locMotionFcn);
draggable(hPlot,'v',[0 1],@locMotionFcn);

%--------------------------
function locMotionFcn(hMoving)  % "currently-moving" handle is passed in
h = get(hMoving,'UserData');  % get the other plot handle
hOther = h(1);
hText = h(2);
switch get(hMoving,'tag')
    case {'lineMean_move','lineMean_rest','linePoints_move','linePoints_rest'}
        yd = get(hMoving,'ydata');
        newMu = mean(yd);
        yOtherOld = get(hOther,'ydata');
        yOtherNew = yOtherOld - mean(yOtherOld) + newMu;
        set(hOther,'YData',yOtherNew);    % update the y data
        set(hText,'string',sprintf('%.2f',newMu))
    otherwise
        warning('daly:bci:unaccountedForCase','do nothing because "drag tag" is "%s"',get(hMoving,'tag'));
end