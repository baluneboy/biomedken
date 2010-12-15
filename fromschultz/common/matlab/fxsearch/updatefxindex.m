function updatefxindex(indexpagePath,isOpenbrowser)
%UPDATEFXINDEX  Update the fxdownloads index file.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula
if nargout == 0
    web('text://<html><body><b>Refreshing the page ...</b></body></html>','-noaddressbox');
end
if (nargin < 2), isOpenbrowser = 1; end

indexPath = fileparts(indexpagePath);

if isOpenbrowser
    mainIndexname = dir(fullfile(fileparts(fileparts(indexpagePath)),'downloads_index.html'));
    if ~isempty(mainIndexname)
        mainindexPath = fileparts(fileparts(indexpagePath));
        mainIndexfilename = fullfile(fileparts(fileparts(indexpagePath)),'downloads_index.html');
    else
        mainindexPath = indexPath;
        mainIndexfilename = indexpagePath;
    end
else
    mainIndexfilename = indexpagePath;
    mainindexPath = indexPath;
end
[allhtmllist,subIndexPath] = getallHtmlList(mainindexPath);
subIndexPath = unique(subIndexPath);
for i=1:length(subIndexPath)
    if ~isempty(subIndexPath{i})
        indexfullfilename = fullfile(subIndexPath{i},'downloads_index.html');
        updatefxindex(indexfullfilename,0);
    end
end
intro = '<h1><center>File Exchange Downloads</center></h1>';

writeIndex(mainIndexfilename,allhtmllist,intro)

if isOpenbrowser 
    %Open the index file
    web(indexpagePath);
end

%==========================================================================
function writeIndex(indexpagePath,allhtmllist,intro)
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
[dirPath fxdirname] = fileparts(fileparts(indexpagePath));
if ~strcmp(fxdirname,'fxdownloads')
    s{end+1} =['<h3 align="center"><a href="matlab: fxgoup(''' indexpagePath ''')" style="text-decoration:none" title="Go up one level">' ...
            '<img src="file:///' strrep(which('fxreturn.png'),'\','/') '"' ... 
            ' style="border:0">My downloads</a></h3>'];
else
    s{end+1} = ['<a href="matlab: checkforUpdates(''' indexpagePath ''',1);" style="text-decoration:none"><b>Check for Updates</b></a>'];
end
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
temp = getSummary(allhtmllist);
for j = 1:length(temp)
    if strcmp(fxdirname,'fxdownloads') && ~isempty(temp{j})
        x = regexp(temp{j},'<a href="matlab: (deletefile.*?);','tokens','once');
        y = regexprep(x{1},')',',1)');
        temp{j} = strrep(temp{j},x{1},y);
    end
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
%==========================================================================
