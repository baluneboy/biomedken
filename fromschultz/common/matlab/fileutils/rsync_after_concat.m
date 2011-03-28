function rsync_after_concat

% FIXME currently this only works to concat "two-part" DCs CNT or SMR files

%% Define some constants
shortPtsMin = 40; % msec for fs = 1000
shortPtsMax = 60; % msec for fs = 1000
longPtsMin = 90; % msec for fs = 1000
longPtsMax = 110; % msec for fs = 1000
strDirEEV = 'E:\Data\EEG_EMG_VICON'; % FIXME for now, works on both DC machines
strCmdSimpleGlob = 'python c:\_workcopy\scripts\python\fileglobber_project\simpleglob.py '; % FIXME get this to work like lazarus' does
strPatternSubjectSessionTask = '(?<prefix>.*).(?<subject>[csn]\d{4}\w{4}).(?<session>\w+).(?<task>\w+)_part_01\....$';

%% Determine type from hostname
strHost = hostname;
switch strHost
    case 'stroke-eeg'
        strType = 'cnt';
    case 'stroke-emg'
        strType = 'smr';
    otherwise
        error('daly:common:badHost','This routine is intended for stroke-eeg or stroke-emg, not to be run on "%s".',strHost);
end % switch

%% Assume established filename convention & gather directories that have files like "*_part_01.cnt" or (.smr)
strPathPattern = fullfile(strDirEEV,['*\*\*_part_01.' strType]);

%% Determine if/which strFileStub's have "two-part" sets that have not yet been concat'ed yet
% LIKE: strFileStub = 'E:\Data\EEG_EMG_VICON\s1818bcis\pre\thumb_extension_forearm_neutral';
[status,strBig] = dos([strCmdSimpleGlob strPathPattern]);

%% Error check
if status~=0
    error('daly:common:badGlob','Problem when trying to run "%s".',[strCmdSimpleGlob strPathPattern]);
end

%% Parse output of glob
casFiles = textscan(strBig,'%s\n');
casFiles = [casFiles{:}];

%% For each "two-part" set, run concattwo if not yet done
for i = 1:length(casFiles)
    strFile = casFiles{i};
    [strDir,strName,strFileStub,strSubject,strSession,strTask] = locParseStub(strFile,strPatternSubjectSessionTask);
    strPatternParts = [strFileStub '_parts02_*.' strType]); % FIXME not "two" mindset here too
    [status,strResult] = dos([strCmdSimpleGlob strPatternParts]);
    if status~=0
        error('daly:common:badGlob','Problem when trying to run "%s".',[strCmdSimpleGlob strPatternParts]);
    end
    if ~isempty(strResult)
        disp([strFileStub ' has been concat''ed'])
    else
        disp([strFileStub ' has NOT been concat''ed'])
        fprintf('\n%s %s %s',strSubject,strSession,strTask)
%         [s1,s2,s12,strFile1,strFile2,strFileCat] = concattwo(strType,strFileStub,shortPtsMin,shortPtsMax,longPtsMin,longPtsMax);
    end
end

%% Write index values to downstream analysis helper db table


%% Call the original rsync script

%-------------------------------------------------------------------------------------------------------------------
function [strDir,strName,strStub,strSubject,strSession,strTask] = locParseStub(strFile,strPatternSubjectSessionTask)
strFileStub = regexprep(strFile,strPatternSubjectSessionTask,'$1\\$2\\$3\\$4');
strSubject = regexprep(strFile,strPatternSubjectSessionTask,'$2');
strSession = regexprep(strFile,strPatternSubjectSessionTask,'$3');
strTask = regexprep(strFile,strPatternSubjectSessionTask,'$4');
[strDir,strName] = fileparts(strFile);