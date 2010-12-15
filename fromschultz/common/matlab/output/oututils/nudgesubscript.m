function nudgesubscript(h);

%nudgesubscript - per Tim's demands, nudge RMS subscripted y labels to left
%                 to give more spacing for y ticks
%
%nudgesubscript(h);
%
%Inputs: h - structure of handles for figure

%Author: Ken Hrovat, 5/20/2003
% $Id: nudgesubscript.m 4160 2009-12-11 19:10:14Z khrovat $

% Nudge YLabels left where there's RMS subscript
for i=1:length(h.AxesALL)
   hAx=h.AxesALL(i);
   yLab=get(hAx,'ylabel');
   strYlabel=get(yLab,'str');
   if hasstr('_{RMS}',strYlabel)
      % put one white space around it
      strNew=strrep(strYlabel,'_{RMS}',' _{RMS} ');
      set(yLab,'str',strNew);
      % nudge ylabel pos to left
      posOld=get(yLab,'pos');
      set(yLab,'pos',[1.3*posOld(1) posOld(2:3)]);
   end
end