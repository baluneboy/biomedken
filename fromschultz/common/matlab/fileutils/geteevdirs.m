function [strViconDir,strEEGDir,strEMGDir,strLaptopDir,strSubjectDir] = geteevdirs(strSubject,strSession)
% geteevdirs.m - returns relevant EEG, EMG, Vicon directories for a
% particular subject/session
% 
% INPUTS
% strSubject - name of subject
% strSession - 'pre' or 'post'
% 
% OUTPUTS
% strViconDir - path where vicon files live
% strEEGDir - path of EEG .cnt file
% strEMGDir - path of EMG .smr file
% strLaptopDir - path of time_delay.mat file
% 
% EXAMPLE
% strSubject = 'c1363plas';
% strSession = 'pre';
% [strViconDir, strEEGDir, strEMGDir, strLaptopDir] = geteevdirs(strSubject, strSession)

% Author - Krisanne Litinas
% $Id$

% Find date of session via database
[foo,strDate] = queryeevsession(strSubject,strSession); %#ok<ASGLU>
iSpace = strfind(strDate,' ');
strDate = strDate(1:iSpace-1);
strDate = strrep(strDate,'-','');

% Vicon
strViconBase = 'S:\data\upper\vicon\dalyUE';

% Parse out which vicon dir based on stroke/tbi or control
strSubjPattern = '(?<strClass>^[ncs])(?<num>\d{4})(?<strStudy>\w{4})';
sSubject = regexp(strSubject,strSubjPattern,'names');
strClass = sSubject.strClass;
switch strClass
    case {'s','n'}
        strCSDir = 'upperStroke';
    case 'c';
        strCSDir = 'upperControl';
    otherwise
        error('daly:eegemgvicon', 'Subject name must start with "c", "n", or "s"')
end
strSubjectViconBase = fullfile(strViconBase,strCSDir,strSubject);
strViconSessionDir = [strDate '_' strSubject];
strViconDir = fullfile(strSubjectViconBase,strViconSessionDir);

% EEG, EMG, Laptop
strDataPath = 'S:\data\upper\eeg_emg_vicon';
strSubjectDir = fullfile(strDataPath,strSubject,strSession);

strEEGDir = fullfile(strSubjectDir,'eeg');
strEMGDir = fullfile(strSubjectDir,'emg');
strLaptopDir = fullfile(strSubjectDir,'vis_stim');

% Check to see if directories exist
locCheckExistance(strViconDir)
locCheckExistance(strEEGDir)
locCheckExistance(strEMGDir)
locCheckExistance(strLaptopDir)

% -------------------------------
function locCheckExistance(strDir)
if ~exist(strDir,'dir')
    error('daly:eegemgvicon:missingdirectory','Directory "%s" does not exist',strDir)
end