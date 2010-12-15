function [hMenu,strFilename]=addprintmenu(hFig,secSpan);

%[hMenu,strFilename]=addprintmenu(hFig);
% needs comments; ex// 2001_06_04_22_10_00_1h15m_121f06_spgs_SampleFilename
%Author: Ken Hrovat, 12/17/2001
% $Id: addprintmenu.m 4160 2009-12-11 19:10:14Z khrovat $

hx=findobj(hFig,'tag','Axes11');
if isempty(hx)
   error('could not find object with tag Axes11')
end
str=get(get(hx,'title'),'str');
[iLeft,iRight,strDelimited]=finddelimited(',','/',str,1);
str=[str(11:iLeft-1) ' ' str(iRight+1:end)];
sdnStart=popdatenum(str,0);
str=popdatestr(sdnStart,-3.1);
secRound=round(str2num(str(end-5:end)));
strStartTime=[str(1:end-6) sprintf('%02d',secRound)];
strPlotType=get(hFig,'name');

hUL1=findobj(gcf,'tag','TextUpperLeft1');
if isempty(hUL1)
   warning('could not find object with tag TextUpperLeft1');
   strSensor='sensorID';
else
   str=get(hUL1,'str');
   [iLeft,iRight,strSensor]=finddelimited(', ',' at',str,1);
end

hComment=findobj(gcf,'tag','TextComment');
if isempty(hComment)
   warning('could not find object with tag TextComment');
   strComment='comment';
else
   strComment=lower(get(hComment,'str'));
end
strBadCharSet='.,/\_( )';
iBad=find(ismember(strComment,strBadCharSet));
strComment(iBad)='';

% Get path for output file
hUR1=findobj(gcf,'tag','TextUpperRight1');
if isempty(hUR1)
   warning('could not find object with tag TextUpperRight1');
   strInc='inc00';
else
   str=get(hUR1,'str');
   [iLeft,iRight,strInc]=finddelimited('Increment:',',',str,1);
   strInc=sprintf('inc%02d',str2num(strInc));
end
str=which('pop');
iPos=findstr(str,['matlab' filesep 'programs']);
strDirname=[str(1:iPos-1) 'batch' filesep 'results' filesep strInc filesep];

% Generate span string
strSpan=secspan2str(secSpan);

u='_';
strFilename=[strStartTime u strSensor u strPlotType u strSpan u strComment];
strFilename=strFilename(1:min([length(strFilename) 60]));
strCSVname=[strFilename '.csv'];

if strcmp(strPlotType(end),'3')
   strPortLand='''portrait''';
   strPaperPos='[0.25 0.32353 8 10.353]';
else
   strPortLand='''landscape''';
   strPaperPos='[0.25 2.40711 8 6.18577]';
end
strCmdPaper=['set(' num2str(hFig) ',''PaperPositionMode'',''manual'',''PaperUnits'',''inches'',''PaperOrientation'',' strPortLand ',''PaperPosition'',' strPaperPos ',''PaperType'',''usletter'');'];
strCmdPrint=[strCmdPaper 'print(''-depsc'',''-tiff'',''-r600'',''' strDirname strFilename ''');'];
strCmdCSV=['gvt2csv(' num2str(hFig) ',''' strDirname strCSVname ''');'];

labels=str2mat( ...
   '&Print', ...
   ['>&Dir: ' strDirname], ...
   ['>&' strFilename], ...
   ['>&' strCSVname], ...
   '>&NewName');
calls=str2mat( ...
   '', ...
   'disp(''EchoDirName'')', ...
   strCmdPrint, ...
   strCmdCSV, ...
   'disp(''InputDialogForNewFilename'')');
hMenu=makemenu(hFig,labels,calls);
