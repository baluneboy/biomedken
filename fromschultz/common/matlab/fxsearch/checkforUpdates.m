function  checkforUpdates(indexpagePath,isfrommainIndex)
%CHECKFORUPDATES  Check updates for all MATLAB Central File Exchange downloads.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula

if (nargin < 2), isfrommainIndex = 0; end

intro = '<h1><center>File Exchange Downloads</center></h1>';
[fid,message] = fopen(indexpagePath,'r');
if fid > 0
    htmlText1 = fread(fid,'char=>char')';
    fclose(fid);
else
    error(message);
end
temp = regexp(htmlText1,'(<tr>.*?</tr>)','match');
updatecount = 0;
for i = 1:length(temp)
    tkFileID = regexp(temp{i},'loadFile\.do\?objectId=(\d+)\>">','tokens','once');
    if ~(length(tkFileID) == 0)
        firstseendate = regexp(temp{i},'Updated on(.*?)\></span>','tokens','once');
        searchResults = ['http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=' tkFileID{1}];
        htmlText2 = urlread(searchResults);
        lastmoddate = regexp(htmlText2,'<td width=100 valign="top">(.*?)<\/td>','tokens','once');
        if ~isempty(lastmoddate) && (datenum(strrep(lastmoddate{1},'-','.'),'yyyy.mm.dd') > fix(datenum(firstseendate{1})))
            %        x = regexp(temp{i},'<h2><a .*>(.*)</a></h2>','tokens','once');
            %        temp{i} = strrep(temp{i},x{1},['<font color="red">' x{1} '</font>']);
            token = regexp(temp{i},'<b>Delete</b></a>(.*)</tr>','tokens','once');
            dirpath = regexp(temp{i},'<a href="matlab: cd\(''(.*?)''\)">','tokens','once');
            temp{i} = regexprep(temp{i},token{1},['\n<a href="matlab: fxdownload(' tkFileID{1} ',0,''' [strrep(fileparts(dirpath{1}),'\','\\') '\\'] '''); checkforUpdates(''' strrep(indexpagePath,'\','\\') ''');" style="text-decoration:none;"><b>&nbsp;&nbsp;&nbsp; Update </b></a>\n<br<br>\n</td>']);
            updatecount = updatecount + 1;
        end
    else
        temp{i} = '';
    end
end

writeIndex(temp,intro,indexpagePath);

if isfrommainIndex
     msgbox(sprintf(' %.0f update(s) found.',updatecount),'Updates');
end

%==========================================================================
function writeIndex(temp,intro,indexpagePath)
%WRITEINDEX  Build a html page.

s = [];
s{1} = '<html><head><title>File Exchange Downloads: My downloads</title>';
% No margin above paragraphs in the description section.
s{end+1} = '<link rel="stylesheet" href="http://www-internal.mathworks.com/devel/sharedemos/styles.css" type="text/css" />';
s{end+1} = '</head>';
s{end+1} = '<body>';

s{end+1} = '<h3 align="right" STYLE="font-size:10pt;color:red">';
s{end+1} = sprintf('Last Updated on: %s',datestr(clock,0));
s{end+1} = '</h3>';

s{end+1} = '<div class="main_intro">';
s{end+1} = intro;
s{end+1} = '</div>';

s{end+1} = '<div>';
s{end+1} = '<table cellspacing="0" border="0" width="100%" id="table1">';
s{end+1} = '<tr>';
s{end+1} = '<td valign="middle" align="left" width="33%">';
s{end+1} = ['<a href="matlab: updatefxindex(''' indexpagePath ''');" style="text-decoration:none"><b>Refresh</b></a>'];
s{end+1} = '</td>';
s{end+1} = '<td valign="middle" align="center" width="33%">';
s{end+1} = ['<a href="matlab: checkforUpdates(''' indexpagePath ''',1);" style="text-decoration:none"><b>Check for Updates</b></a>'];
s{end+1} = '</td>';
s{end+1} = '<td valign="middle" align="right" width="33%">';
s{end+1} = ['<form method="post" action="matlab:fxsearch"><h3>Search: <input type="text" name="searchstr" value="">&nbsp;<input type="submit" value="Submit"><br>' ...
            '<a href="matlab: fxsearch(''recent'',15,1);" style="text-decoration:none;font-size:small">Top 15 recent files</a>, ' ...
            '<a href="matlab: fxsearch(''popular'',15,1);" style="text-decoration:none;font-size:small">Top 15 popular files</a>&nbsp;&nbsp;&nbsp;&nbsp;</h3></form>'];

s{end+1} = '</td>';
s{end+1} = '</tr>';
s{end+1} = '</table>';

s{end+1} = '<table cellspacing="0" class="t1">';

% Make web page
%Check if any file is downloaded. If downloaded sort the list according to
%the date and append it at the bottom.
for j = 1:length(temp)
    s{end+1} = temp{j};
end

s{end+1} = '</table>';

s{end+1} = '<p>';

s{end+1} = '</div></body></html>';

% Save out the file

[fid,message] = fopen(indexpagePath,'w+');
if fid > 0
    for n = 1:length(s)
        fprintf(fid,'%s\n',s{n});
    end
    fclose(fid);
else
    error(message);
end
web(indexpagePath);
