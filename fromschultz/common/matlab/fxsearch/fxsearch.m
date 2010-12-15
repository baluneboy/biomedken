function fxsearch(searchstr,maxResults,isCategory)
%FXSEARCH  Search MATLAB Central File Exchange.
%
%   FXSEARCH(searchstr) searches file exchange with searchstr and returns
%   the results in a html page. The format of this html page is, it includes
%   information like title, description, thumbnail, author name and links
%   associated with it for each match found. For easy download there will be a
%   download button for each match found. Default is 'file exchange'. The
%   result file is saved in tempdir.
%
%   FXSEARCH(searchstr,maxResults) searches file exchange with
%   searchstr and returns maxResults no. of results in a html page. By
%   default maxResults is 20.
%
%   FXSEARCH(searchstr,maxResults,isCategory) search has 2 options. If
%   isCategory is set to 0(default), searches file exchange with searchstr.
%   If isCategory is set 1, searchstr is a keyword. The keywords are recent
%   and popular and returns top 15 files.
%
%   Example:
%     fxsearch('google')
%     fxsearch('filter',10) 
%     fxsearch('recent',10,0)

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula

if nargout == 0
    web('text://<html><body>Generating search results ...</body></html>','-noaddressbox');
end

if (nargin < 1), searchstr = ''; end
if (nargin < 2), maxResults = 20; end
if (nargin < 3), isCategory = 0; end


mainIntro = '<h1><center>MATLAB Central File Exchange Search</center></h1>';
token = regexp(searchstr,'\?searchstr=(.*)','tokens','once');
if ~(length(token) == 0)
    searchstr = strrep(token{1},'+',' ');
end
if isCategory
    maxLimit = 15;
    switch searchstr
        case 'recent'
            searchUrl = 'http://www.mathworks.com/matlabcentral/fileexchange/loadFileList.do?objectType=fileexchange&orderBy=date&srt3=0';
        case 'popular'
            searchUrl = 'http://www.mathworks.com/matlabcentral/fileexchange/loadFileList.do?objectType=fileexchange&orderBy=totalDown&srt4=0';
    end
htmlText = urlread(searchUrl);
tkFileID = regexp(htmlText,'loadFile\.do\?objectId=(\d+)','tokens');
tkFileID = tkFileID(1:min(length(tkFileID),min(maxLimit,maxResults)));
else
    keyword = strrep(searchstr,' ','%20');
    searchUrl = ['http://www.mathworks.com/matlabcentral/fileexchange/loadFileList.do?search_submit=fileexchange&query=goto&search=+Go+&objectType=search&criteria=' keyword];
    htmlText = urlread(searchUrl);
    tkFileID = regexp(htmlText,'loadFile\.do\?objectId=(\d+)','tokens');
    tkFileID = tkFileID(1:min(length(tkFileID),maxResults));
end    
%web(searchUrl)
d = [];
for i=1:length(tkFileID)
    fileid = tkFileID{i}{1};
    searchResults = ['http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=' fileid];
    htmlText = urlread(searchResults);

    d(i).filename = regexp(htmlText,'"fileName" value="(.*?)">','tokens','once');
    %contributorId
    contributorId = regexp(htmlText,'"contributorId" value="(.*?)">','tokens','once');

    %Get the relevant information in a structure
    d(i).fileid = fileid;
    d(i).title = regexp(htmlText,'<tr><td width=70% class=headercell height=20>&nbsp;(.*?)&nbsp;','tokens','once');
    d(i).description = regexp(htmlText,'<td width="456" class="lnwrp">(.*?)</td>','tokens','once');
    %Category
    %token = regexp(htmlText,'Required Products:(.*?)</tr>','tokens','once');
    %if ~isempty(token)
    %    token1 = regexp(token{1},'<td height="15" colspan="2">(.*?)</td>','tokens','once');
    %    d(i).category = regexprep(token1{1},'[/,\s]','_');
    %else
    d(i).category = '';
    %end
    %d(i).categoryurl = ['http://www.mathworks.com/matlabcentral/fileexchange/loadCategory.do?objectId=' sprintf('%.0f',rst1.Data{12})];
    d(i).author = strrep(regexp(htmlText,['<a .*objectId=' contributorId{1} '">(.*?)</a>'],'tokens','once'),'&nbsp;','_');

    d(i).authorurl = ['http://www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do?objectType=author&objectId=' contributorId{1}];
    d(i).date = datenum(clock);
    d(i).ratinglink = ['http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=' d(i).fileid '&objectType=file#review_submission'];
    d(i).link = strcat('http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=', d(i).fileid);

    %Thumbnail url
    thumbnailUrl = regexp(htmlText,'<td id="scrnshot" valign="top">.*imgName=(.*?)" onClick','tokens','once');

    if ~isempty(thumbnailUrl)
        d(i).thumbnailUrl = strcat(['http://www.mathworks.com/matlabcentral/files/' d(i).fileid '/'], thumbnailUrl{1});
    else
        d(i).thumbnailUrl = '';
    end

    %Finding Links Text
    token = regexp(htmlText,'What are<br/>Published M-files.*\< <td height="15" colspan="2">(.*?)</td>','match');
    if ~isempty(token)
        %Findig links
        fileurls = regexp(token{1},'(http.*?\.html)','match');
        %Finding Links Titles
        fileurlnames = regexp(token{1},'w.focus\();">(.*?)<','tokens');
        for j=1:length(fileurls)
            d(i).fileurls{j} = fileurls{j};
            d(i).fileurlnames(j) = fileurlnames{j};
        end
    else
        d(i).fileurls = '';
        d(i).fileurlnames = '';

    end
end
%Create an index page for all downloads
writeIndex(mainIntro,d,searchstr);
%cd (indexPath)
%==========================================================================
function writeIndex(mainIntro,d,searchstr)
%WRITEINDEX  Build a html page.

s = [];
s{1} = '<html><head><title>File Exchange Search Results</title>';
% No margin above paragraphs in the description section.
s{end+1} = '<link rel="stylesheet" href="http://www-internal.mathworks.com/devel/sharedemos/styles.css" type="text/css" />';
s{end+1} = '</head>';
s{end+1} = '<body>';

s{end+1} = '<div class="main_intro">';
s{end+1} = mainIntro;
s{end+1} = '</div>';

s{end+1} = '<br>';
s{end+1} = '<table cellspacing="0" cellpadding = "0" width="100%" border = "0" style="color:black">';
s{end+1} = '<tr>';
s{end+1} = '<td valign="top" align ="left" width="30%">';
s{end+1} = '<a href="matlab: showfxdownloads();" style="text-decoration:none"><h3>My downloads</h3></a>';
s{end+1} = '</td>';
s{end+1} = '<td valign="top" align ="center" width="35%">';
s{end+1} = '<a href="matlab: fxselectdir();" style="text-decoration:none"><h3>Select download directory</h3></a>';
s{end+1} = '</td>';
s{end+1} = '<td valign="top" align ="right" width="35%">';
s{end+1} = ['<form method="post" action="matlab:fxsearch"><h3>Search: <input type="text" name="searchstr" value="">&nbsp;<input type="submit" value="Submit"><br>' ...
            '<a href="matlab: fxsearch(''recent'',15,1);" style="text-decoration:none;font-size:small">Top 15 recent files</a>, ' ...
            '<a href="matlab: fxsearch(''popular'',15,1);" style="text-decoration:none;font-size:small">Top 15 popular files</a>&nbsp;&nbsp;&nbsp;&nbsp;</h3></form>'];
s{end+1} = '</td>';
s{end+1} = '</tr>';

s{end+1} = '<div>';
if ~isempty(searchstr)
    s{end+1} = '<tr>';
    s{end+1} = '<td valign="top" align ="left">';
    s{end+1} = ['Search results for : <b>' searchstr '</b>'];
    s{end+1} = '</td>';
    s{end+1} = '<td valign="top" align="right" colspan="2">';
    s{end+1} = sprintf('<b>%.0f</b> matches found.',length(d));
    s{end+1} = '</td>';
    s{end+1} = '</tr>';
end
s{end+1} = '</table>';

s{end+1} = '<table cellspacing="0" class="t1">';
for i=1:length(d)

    s{end+1} = '<tr>';
    s{end+1} = '<td valign="top" class="td1">';
    %Thumbnail
    if ~isempty(d(i).thumbnailUrl)
        s{end+1} = sprintf('<a href="%s"><img src="%s" border="0" width="84" height="64"></a>',d(i).thumbnailUrl,d(i).thumbnailUrl);
    else
        s{end+1} = '&nbsp;';
    end
    s{end+1} = '</td>';

    s{end+1} = '<td valign="top" class="td1">';

    % Title
    if ~isempty(d(i).title)
        demotitle = d(i).title{1};
    else
        demotitle = d(i).filename{1};
    end
    s{end+1} = sprintf('<h2><a href="%s">%s</a></h2>', ...
        d(i).link,demotitle);

    % Gray info line
    s{end+1} = '<span class="dim">';
    % Author
    s{end+1} = sprintf('<a href="%s">%s</a>', ...
        d(i).authorurl,strrep(d(i).author{1},'_',' '));
    s{end+1} = '</span><br>';
    %Related html links for a file
    if ~isempty(d(i).fileurls)
        s{end+1} = '<p><ul>';
        for j=1:length(d(i).fileurls)
            s{end+1} = sprintf('<li><a href="%s">%s</a></li>',d(i).fileurls{j}, d(i).fileurlnames{j});
        end
        s{end+1} = '</p></ul>';
    end
    % Description
    s{end+1} = '<br>';
    if ~isempty(d(i).description)
        s{end+1} = d(i).description{1};
    end
    s{end+1} = '<br>';
    s{end+1} = ['<a href="matlab: fxdownload(' d(i).fileid ');" style="text-decoration:none"><b>&nbsp;&nbsp;Download</b></a>'];
    s{end+1} = '</td>';
    s{end+1} = '</tr>';
end

s{end+1} = '</table>';

s{end+1} = '<p>';

s{end+1} = '</div></body></html>';

% Save out the file

[fid,message] = fopen(fullfile(tempdir,'searchResults.html'),'w+');
if fid > 0
    for n = 1:length(s)
        fprintf(fid,'%s\n',s{n});
    end
    fclose(fid);
else
    error(message);
end
clear(fullfile(tempdir,'searchResults.html'));
web(fullfile(tempdir,'searchResults.html'));

%==========================================================================
