function sText = createfigure_ancillarytext(strSubject,strSetting,strTask,strSession,strDateCollected,strId,strFile)

% EXAMPLE:
% strSubject = 'subject';
% strSetting = 'setting';
% strTask = 'the_task_goes_here';
% strSession = 'sessionNN';
% strDateCollected = 'dateCollected';
% strId = 'SIdS';
% strFile = '/the/complete/path/to/the/file/goes/h.ere';
% sText = createfigure_ancillarytext(strSubject,strSetting,strTask,strSession,strDateCollected,strId,strFile);

% Create upperleft text
sText.casUpperLeft = {strSubject,strSetting,strTask,strSession};

% Create upperright text
sText.casUpperRight = {'nameOfPlot',sprintf('DC:%s',strDateCollected)};

% Create lowerright text
sText.casLowerRight = {[datestr(now,2) ' ' datestr(now,15)],strId};

% Create lowerleft text
sText.casLowerLeft = {strFile};
