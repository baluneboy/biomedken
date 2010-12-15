function citation = fxcite(fileid)
%FXCITE  Return citation of a file.
%
%   CITATION = FXCITE(fileid) returns citation of a specified fileid.
%
%   Example:
%     citation = fxcite(1613)

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula

searchstr = ['http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=' sprintf('%.0f',fileid)];
htmlText = urlread(searchstr);
contributorId = regexp(htmlText,'"contributorId" value="(.*?)">','tokens','once');
d.title = regexp(htmlText,'<tr><td width=70% class=headercell height=20>&nbsp;(.*?)&nbsp;','tokens','once');
d.author = strrep(regexp(htmlText,['<a .*objectId=' contributorId{1} '">(.*?)</a>'],'tokens','once'),'&nbsp;','_');
d.date = datenum(clock);
citation = sprintf([' %% \n %% This file contains code courtesy of %s, "%s"' ...
            '\n %% from the MATLAB Central File Exchange. Retrieved %s. ' ...
            '\n %% %s \n %%'],strrep(d.author{1},'_',' '),d.title{1},datestr(d.date),searchstr);
