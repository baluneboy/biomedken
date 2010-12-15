function setdateaxis(t,sHandles,sHeader,sPlot);

% Authors: Ken Hrovat & Eric Kelly
% $Id: setdateaxis.m 4160 2009-12-11 19:10:14Z khrovat $

% Get time vector with units
ut=t*units(sPlot.TUnits);
sdn=sHeader.sdnDataStart+double(convert(ut,'days'));

% Set xdata of image/line object(s) to sdn values
if isfield(sHandles,'ImageALL')
   set(sHandles.ImageALL,'xd',sdn);
elseif isfield(sHandles,'LineALL')
   set(sHandles.LineALL,'xd',sdn);
else
   error('could not find ImageALL or LineALL field for date axis')
end

switch sPlot.TLimMode
case 'auto'
  % Set axes props
set(sHandles.AxesALL,'xlimmode','manual');
set(sHandles.AxesALL,'xlim',[sdn(1) sdn(end)]);
set(sHandles.AxesALL,'xtickmode','auto');

% Manually do "nice" time ticks
hx=sHandles.TextXLabel;
hAx=get(hx,'parent');
xticks=get(hAx,'xtick');
numTicks=length(xticks);
dtick=xticks(2)-xticks(1);
set(sHandles.AxesALL,'xtick',sdn(1):dtick:sdn(end));

case 'manual'   
% Manually do "nice" time ticks
hx=sHandles.TextXLabel;
hAx=get(hx,'parent');
xticks=get(hAx,'xtick'); 

uxticks=xticks*units(sPlot.TUnits);
sdnxticks = sHeader.sdnDataStart+double(convert(uxticks,'days'));

endlim=get(sHandles.AxesALL,'xlim');
if iscell(endlim)
   dendlim=endlim{1}(2)*units(sPlot.TUnits); % KH: for multi-axes figure
else
   dendlim=endlim(2)*units(sPlot.TUnits);    % KH: for one-axes figure
end
uendlim = sHeader.sdnDataStart+double(convert(dendlim,'days'));

% Set axes props
set(sHandles.AxesALL,'xlimmode','manual');
set(sHandles.AxesALL,'xlim',[sdnxticks(1) uendlim]);
set(sHandles.AxesALL,'xtick',sdnxticks);
%set(sHandles.AxesALL,'xlim',[sdnxticks(1) sdnxticks(end)]);
%set(sHandles.AxesALL,'xtickmode','auto');

otherwise
   error('unknown TLimMode')
end

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
strStart=strrep(get(sHandles.TextTitle,'str'),'Start ','');
iSlash=findstr(strStart,'/');
strStart=strStart(1:iSlash);
set(hx,'string',[strStart sPlot.TTickForm])
