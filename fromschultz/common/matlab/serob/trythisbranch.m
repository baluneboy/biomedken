function trythisbranch

%
% trythisbranch - unobtrusive intro to roboprocessing
%
% Putting "script-like" routines into functions shields workspace variables
% from being clobbered. We will, in this function, manipulate the path, but
% we will put it back the way we found it; going so far as to use try-catch
% so that errors will trip a restoration of path.  This whole path deal is
% intended to let Morgan continue development thread she's been, while
% Ken branched to get back to roboprocess needed for ongoing analysis.
%
% INPUTS:
% none
%
% OUTPUTS:
% none
%
% EXAMPLE
% trythisbranch

% Author: Ken Hrovat
% $Id: trythisbranch.m 4160 2009-12-11 19:10:14Z khrovat $

% Swap paths robo\trunk with robo\branches\chasebat (just for this function)
strOldpath = path;
strNewpath = regexprep(strOldpath,['robo' filesep 'trunk'],['robo' filesep 'branches' filesep 'chasebat']);
path(strNewpath);

try

    % Show sample pass at roboprocess
    strVerbosity = 'some'; % 'very' or 'some' OR 'execute'
    strDir = [getdatapath 'upper' filesep 'serob' filesep 'therapist'];
    casKeep = {'eval'}; % filter in
    casSkip = {'therapy'}; % filter out
%     locPass(strVerbosity,strDir,casKeep,casSkip);

    % Show more details
    strVerbosity = 'very'
    locPass(strVerbosity,strDir,casKeep,casSkip);

catch

    warning('something went awry...')

end

path(strOldpath)


% ----------------------------------------------------------------------
function [str,minElapsed] = locPass(strVerbosity,strDir,casKeep,casSkip)
tZero=clock;
strConf = fullfile(getlogpath,'chase_process_list.txt');
strPattern = '^chase_rob_(?<hhmmss>\d{6})_ball_(?<numBall>\d{1,2})\.dat$';
strWild = 'chase_rob*.dat';
warning('off','roboreadpro:DuplicateField'); % to suppress pro read issue
fprintf('\n\nPlease wait, gathering info from %s\n',strDir)
s = get_chase_sessions(strPattern,strWild,strDir,casKeep,casSkip);
str = show_chase(s,strConf,strVerbosity);
warning('on','roboreadpro:DuplicateField'); % to not suppress pro read issue
minElapsed = etime(clock,tZero)/60;
fprintf('\nWe found the following:\n%s',str)
fprintf('\nand the above took %.1f minutes to process.\n',minElapsed)