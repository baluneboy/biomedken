function strImageFilename=genimgfilename(sdnTitleStart,strComment,strID,strType,strWhichAx,iPlot,strExt);

strStartTime=strrep(popdatestr(sdnTitleStart,-2),':','_');
iDot=findstr(strStartTime,'.');
strStartTime=strStartTime(1:iDot-1);
strComment=locRemoveUnd(strComment);
strComment=strrep(strComment,' ','');
strID=locRemoveUnd(strID);
strID=strrep(strID,'hirap','mhirap');
strType=locRemoveUnd(strType);
strWhichAx=locRemoveUnd(strWhichAx);
strExt=locRemoveUnd(strExt);

% Abbreviate WhichAx from structure of plot parameters
switch strWhichAx
case {'x','y','z'}
   % single char ok
case 'sum'
   strWhichAx='s';
case 'vecmag'
   strWhichAx='m';
case 'xyz'
   strWhichAx='3';
otherwise
   error('unknown axis string')
end

u='_';
%strImageFilename=[strComment u strID u strType strWhichAx u sprintf('%03d.',iPlot) strExt];
strImageFilename=[strStartTime u strID u strType strWhichAx u strComment u sprintf('%03d.',iPlot) strExt];%2001_05_23_00_15_00_mhirap_spgs_ProgressDock.eps

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str=locRemoveUnd(strU);
str=strrep(strU,'_','');