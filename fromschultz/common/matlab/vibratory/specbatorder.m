function [casFiles,sdnFileBegins]=specbatorder(casFiles);

%specbatorder - chrono sort cell array of specbat files.
%
%[casFiles,sdnFileBegins]=specbatorder(casFiles);
%
%Input: casFiles - cell array of strings specbat filenames
%
%Output: casFiles - sorted cell array of strings specbat filenames
%        sdnFileBegins - serial date numbers for start times of each specbat file

%written by: Ken Hrovat on 6/30/2001
% $Id: specbatorder.m 4160 2009-12-11 19:10:14Z khrovat $

% Get char array of filenames
charFiles=str2mat(casFiles{:});

% Flip left-right for convenience
charFlipFiles=fliplr(charFiles);

% Toss ".mat" part
charFlipFiles(:,1:4)=[];

% Replace second's underscore
charFlipFiles(:,4)='.';

% Toss all but raw time string
charFlipFiles(:,24:end)=[];

% Flip back again
charFiles=fliplr(charFlipFiles);

% Replace underscores with commas
charTemp=charFiles';
charTemp([5 8 11 14 17],:)=',';
charFiles=charTemp';

% Loop to eval filenames into sdn values
numFiles=nRows(charFiles);
sdnFileBegins=nan*ones(numFiles,1);
fprintf('\nLooping to eval filenames into sdn values ... ')
for k=1:nRows(charFiles)
   strCommand=sprintf('sdnFileBegins(%d)=datenum(%s);',k,charFiles(k,:));
   eval(strCommand);
end
fprintf('done.')

% Sort for chrono order
fprintf('\nSorting by sdn values ... ')
[sdnFileBegins,iSort]=sort(sdnFileBegins);
casFiles=casFiles(iSort);
fprintf('1st starts at %s & ',datestr(sdnFileBegins(1)))
fprintf('last starts at %s.',datestr(sdnFileBegins(end)))