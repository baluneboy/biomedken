function s = viconread(strFile)

%
% put good help/comments here, but for now...
%
% EXAMPLES:
% strFile = 'S:\data\upper\smallfile.txt';
% s = viconread(strFile);
%

% Author: Ken Hrovat
% $Id: viconread.m 4160 2009-12-11 19:10:14Z khrovat $

% Call cygwin perl parse script [matlab version of perl did not work!?]
strLineInfo = locPerl('viconparse.pl',strFile);

% Get info parsed via perl
[nFirsts,nLasts,casHeaders] = strread(strLineInfo,'%d,%d,%s\n');

% Loop over chunks (yikes)
for i = 1:length(nFirsts)
    s(i).firstLine = nFirsts(i);
    s(i).lastLine = nLasts(i);
    s(i).strHeader = casHeaders{i};
    s(i).data = locGetChunk(strFile,s(i)); % first,last,hdr in s at this pt
end

% -----------------------------------
function data = locGetChunk(strFile,s)
numLines = s.lastLine - s.firstLine + 1;
numFields = length(findstr(s.strHeader,','))+1;
strFmt = repmat('%f',1,numFields);
fid = fopen(strFile);
c = textscan(fid,strFmt,numLines,'delimiter',',','headerlines',s.firstLine-1,'collectoutput',1);
data = c{1};
fclose(fid);

% ---------------------------------------------
function strOut = locPerl(strPerlScript,strFile)
strScript = which(strPerlScript);
strCmd = ['"c:\cygwin\bin\perl.exe" "' strScript '" ' strFile];
[s,strOut] = unix(strCmd);