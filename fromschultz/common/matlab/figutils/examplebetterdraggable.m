function examplebetterdraggable
% EXAMPLE
% examplebetterdraggable; % drag red line to new pos, then right-click it

% FIXME add "snap draggable" as option in cmenu too

%% Plot 
hFig = figure;
hLine = plot(humps);
hAx = get(hLine,'Parent');
ylim = get(hAx,'YLim');
originalX = 10;
hImLine = imline(gca,originalX*[1 1],ylim);
hImLineKids = get(hImLine,'children');
get(hImLineKids(3),'color')
set(hImLineKids(1:3),'color','r');
set(hImLineKids(1:2),'ButtonDownFcn',[],'vis','off');
api = iptgetapi(hImLine);
fcn = makeConstrainToRectFcn('imline',get(hAx,'XLim'),get(hAx,'YLim')); % restrain to current ax lims
api.setDragConstraintFcn(fcn);

%% Set up my context menu
cmenu = uicontextmenu('Parent',hFig);
% FIXME add infrastructure to do both "restore original x" & "restore previous x"
uimenu(cmenu, 'Label', 'RestoreX', 'Callback', {@locCmenuCallback,api,originalX});
set(findobj(hImLine,'Type','line'), 'UIContextMenu', cmenu);

%----------------------------------
function locCmenuCallback(varargin)
% handle to figure is varargin{1}
% eventdata is varargin{2} [always empty?]
api = varargin{3};
originalX = varargin{4};
currPos = api.getPosition();
newPos = currPos;
newPos(1) = originalX;
newPos(2) = originalX;
api.setPosition(newPos);