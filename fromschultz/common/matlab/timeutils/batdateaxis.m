function batdateaxis(t,sHandles,sHeader,sPlot);

% Get time vector with units
ut=t*units(sPlot.TUnits);
sdn=sHeader.sdnDataStart+double(convert(ut,'days'));
%sdn=locSnapTime(sHeader.sdnDataStart)+double(convert(ut,'days'));

% Handle matlab bug
sdn=locNudgeTime(sdn);

% Set xdata of image/line object(s) to sdn values
if isfield(sHandles,'ImageALL')
   set(sHandles.ImageALL,'xd',sdn);
elseif isfield(sHandles,'LineALL')
   set(sHandles.LineALL,'xd',sdn);
else
   error('could not find ImageALL or LineALL field for date axis')
end

% Set axes props
set(sHandles.AxesALL,'xlimmode','manual');
set(sHandles.AxesALL,'xlim',[sdn(1) sdn(end)]);
set(sHandles.AxesALL,'xtickmode','auto');

% Manually do "nice" time ticks
hx=sHandles.TextXLabel;
hAx=get(hx,'parent');

% Get tick step size for "nice" time ticks
durationMinutes=double(convert(t(end)*units(sPlot.TUnits),'minutes'));
if (durationMinutes>20 & durationMinutes<60)
   sdnTickStep=1/144; % 10 minutes
elseif (durationMinutes>=60 & durationMinutes<90)
   sdnTickStep=1/96; % 15 minutes
elseif (durationMinutes>=90 & durationMinutes<240)
   sdnTickStep=1/48; % 30 minutes
elseif (durationMinutes>=240 & durationMinutes<480)
   sdnTickStep=1/24; % 1 hour
elseif durationMinutes>=480
   sdnTickStep=1/12; % 2 hours
else
   set(hAx,'xtickmode','auto');
   xticks=get(hAx,'xtick');
   numTicks=length(xticks);
   sdnTickStep=xticks(2)-xticks(1);
end

% Get 8-hour ticks
xt=[(0:8);(8:16);(16:24)]/24;
portion=locDeterminePortion(sdn(1));
dayPart=locGetStartDayTick(sdn(1));
xTicks=dayPart+xt(portion,:);
%sdnLeftMostTick=locSnapTime(sdn(1));
%sdnRightMostTick=locSnapTime(sdn(end));
%xTicks=sdnLeftMostTick:sdnTickStep:sdnRightMostTick;
set(sHandles.AxesALL,'xlimmode','manual');
set(sHandles.AxesALL,'xlim',[xTicks(1) xTicks(end)]);
set(sHandles.AxesALL,'xtick',xTicks);

% Branch to desired dateform
axes(hAx);
switch sPlot.TTickForm
case 'hh:mm:ss'
   dateaxis('x',13);
case 'hh:mm'
   dateaxis('x',15);
otherwise
   error('unknown TTickForm')
end

% Replace old xlabel with new one
set(hx,'string',sPlot.TTickForm)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function portion=locDeterminePortion(sdn1);
fracOfDay=rem(sdn1,1);
gridmin=0;
gridstep=1/3; % hourly
gridmax=2/3;
lean=0;
newFracOfDay=snap2grid(fracOfDay,gridmin,gridstep,gridmax,lean);
portion=round(3*(newFracOfDay))+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dayPart=locGetStartDayTick(sdn1);
fracOfDay=rem(sdn1,1);
if fracOfDay>0.5
   dayPart=floor(sdn1);
else
   dayPart=round(sdn1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sdnNew=locSnapTime(sdnOld);
gridmin=0;
gridstep=1/24/12; % 5 minutes
gridmax=1-gridstep;
lean=0;
fracOfDay=rem(sdnOld,1);
if fracOfDay>0.993
   sdnNew=fix(sdnOld)+1;
   newFracOfDay=0;
else
   newFracOfDay=snap2grid(fracOfDay,gridmin,gridstep,gridmax,lean);
   sdnNew=fix(sdnOld)+newFracOfDay;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sdnNudged=locNudgeTime(sdn);
% Like in popdatestr, don't ask why we need this (MATLAB bug)
sdnNudged=sdn;
secs=second(sdn);
iBad=find(secs>59.999);
secAdd=1e-4;
sdnNudged(iBad)=sdnNudged(iBad)+(secAdd/86400);
sdnNudged=sdnNudged+1.1e-8;