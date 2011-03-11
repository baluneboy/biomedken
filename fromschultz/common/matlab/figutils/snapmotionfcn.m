function snapmotionfcn(hMoving)
% snapmotionfcn used with draggable; note: currently moving handle is input
%
% EXAMPLE
% h1 = plot(1:11,randn(11,1)); % the line who's xdata we snap to
% hold on;
% h2 = plot([1 1],[0 1],'r'); % initial snap line
% ud = get(h2,'UserData'); % we are gonna stash xdata we snap to here
% ud.xdata = get(h1,'xdata');
% ydata = get(h1,'ydata');
% ymin = min(ydata);
% ymax = max(ydata);
% ycushion = 0.1*abs(ymax-ymin);
% ud.ymin = ymin-ycushion;
% ud.ymax = ymax+ycushion;
% set(h2,'UserData',ud)
% axis('auto');
% hold off;
% draggable(h2,'horizontal',@snapmotionfcn)
  xd = get(hMoving,'XData');
  ud = get(hMoving,'UserData');
  [foo,imin] = min(abs(ud.xdata-xd(1)));
  xsnap = ud.xdata(imin);
  set(hMoving,'XData',xsnap*[1 1],'YData',[ud.ymin ud.ymax]);
end