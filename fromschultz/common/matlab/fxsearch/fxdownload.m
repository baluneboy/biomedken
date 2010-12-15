function fxdownload(fileid,isselectPath,indexPath)
%FXDOWNLOAD  Download a file from MATLAB Central File Exchange.
%
%   FXDOWNLOAD(fileid) downloads a file with specified fileid into the
%   indexPath\fxdownloads directory. The indexPath is the downloads
%   location, retrieved from previous download. If downloading for the
%   first time it will prompt the user to select the download directory. If
%   the downloading file is a zip file, it will extracts the archived
%   contents of the file or else for all other formats just downloads the
%   file. These files are downloaded into a directory with name format
%   [filename][fileid] and after the download is complete it will CD to
%   this directory and opens up fxsummary.html page.
%
%   FXDOWNLOAD(fileid,isselectPath) downloads the file with specified
%   fileid with an option of selecting a indexPath, if isselectPath
%   is 1. If isselectPath is 0 indexPath is choosen from previous download.
%
%   FXDOWNLOAD(fileid,isselectPath,indexPath) downloads the file with
%   specified fileid with an option of passing indexPath. When passing an
%   indexPath isselectPath should be 0. If isselectPath is 1 it will
%   prompt the user to choose indexPath and overwrites the value that is
%   passed.
%
%   Example:
%     fxdownload(1613)
%     fxdownload(1613,1)
%     fxdownload(1613,0,'C:\matlab')
%
%   NOTE: 1.Fileid can be found in MATLAB Central->File Exchange site.
%         2.For every new indexPath, this function will
%         create a fxdownloads directory with in indexPath and then
%         download the file into respective file name. If for the
%         next download another directory, one level above or below the
%         fxdownloads, is choosen then it will not create fxdownloads
%         directory again. It will download the file into previous
%         fxdownloads directory.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula

%default is set to 0 to get the value from getpref
if (nargin < 2), isselectPath = 0; end
if (nargin < 3), indexPath = ''; end

mainIndexPath = fullfile(fileparts(prefdir),'fxdownloads');
[indexPath,rootPath] = selectIndexPath(isselectPath,indexPath,mainIndexPath);
%exit if no indexPath is selected
if rootPath == 0
    return
end

intro = '<h1><center>File Exchange Downloads</center></h1>';
indexHtmlFilename = 'downloads_index.html';

searchstr = ['http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=' sprintf('%.0f',fileid)];
htmlText = urlread(searchstr);
filename = strrep(regexp(htmlText,'"fileName" value="(.*?)">','tokens','once'),' ','%20');

%File Extention
fe = regexp(htmlText,'name="fileExt" value="(.*?)">','tokens','once');
%contributorId
contributorId = regexp(htmlText,'"contributorId" value="(.*?)">','tokens','once');

%Download file URL
downloadFileURL = ['http://www.mathworks.com/matlabcentral/fileexchange/download.do?objectId=' sprintf('%.0f',fileid) ...
    '&fn=' filename{1} '&fe=' fe{1} '&cid=' contributorId{1}];

%Create a donwloaDir
[downloadDir,dirname,isOverWrite] = createdownloadDir(indexPath,fileid,filename);
if strcmp(isOverWrite,'Cancel')
    return
end

%download file
unzipfilenames = downloadfile(downloadFileURL,downloadDir,filename,fe);

%Get the relevant html info in a structure
d = relevantHtmlInfo(htmlText,fileid,filename,dirname,downloadDir,contributorId,unzipfilenames);

%Create an index page for all downloads in a particular location
writeIndex(indexPath,indexHtmlFilename,downloadDir,intro,d);

%Create a summary page for each individual download
createSummaryPage(indexPath,indexHtmlFilename,downloadDir)

%Create main index for all downloads in all locations
[dirPath fxdirname] = fileparts(fileparts(indexPath));
if strcmp(fxdirname,'fxdownloads')
    updatefxindex(fullfile(fileparts(indexPath),indexHtmlFilename),0);
end

%open fxsummary page
web(fullfile(downloadDir,'fxsummary.html'));

%==========================================================================
function [indexPath,rootPath] = selectIndexPath(isselectPath,indexPath,mainIndexPath)
%SELECTINDEXPATH  Select a direcoty to download a file.

%get the indexPath from the preference already set if indexPath is not
%passed
if ispref('fileexchange','prefindexPath') && isempty(indexPath)
    indexPath = getpref('fileexchange','prefindexPath');
end
rootPath = '';
%get the user input for indexPath if it is empty or user want to change the
%indexPath preference.
if isempty(indexPath) || isselectPath
    rootPath = uigetdir(cd,'Select a folder');
    %
    if rootPath == 0
        %exit if no directory is choosen
        return;
    end
    cd(rootPath);
    [dirpath filename ext] = fileparts(rootPath);
    %check the validity of the directory
    if isempty(ext)
        %check if the directory choosen is fxdownloads. if fxdownloads direcoty
        %is choosen assign user selected directory as indexPath or else
        %create a fxdownloads directory and assign it indexPath
        if ~isempty(filename)
            [localdirPath localFilename] = fileparts(dirpath);
            if ~strcmp(filename,'fxdownloads') && ~strcmp(localFilename,'fxdownloads')
                [subdirpath subfilename] = fileparts(dirpath);
                if strcmp(subfilename,'fxdownloads')
                    indexPath = rootPath;
                else
                    if ~isdir('fxdownloads')
                        [status, message, mesageid] = mkdir('fxdownloads');
                        if status == 0
                            errordlg([mesageid ': ' message],'Error');
                        end
                        indexPath = fullfile(rootPath,'fxdownloads');

                    else
                        indexPath = fullfile(rootPath,'fxdownloads');
                    end
                end
            else
                indexPath = rootPath;
            end
        else
            indexPath = fullfile(rootPath,'fxdownloads');
        end
        if ispref('fileexchange','prefindexPath')
            setpref('fileexchange','prefindexPath',indexPath);
        else
            addpref('fileexchange','prefindexPath',indexPath);
        end
    else
        errordlg('Invalid filname.', 'Error');
    end
end
%check if prefindexPath preferece is already existing if not add prefindexPath
%preference to fileexchange group
saveindexPath(indexPath,mainIndexPath);


%==========================================================================
function saveindexPath(indexPath,mainIndexPath)
%SAVEINDEXPATH  Save the selected indexPath into a mat file.

if ~isdir(mainIndexPath)
    mkdir(mainIndexPath)
end
filename = dir(fullfile(mainIndexPath,'indexPathList.mat'));
if ~isempty(filename)
    load(fullfile(mainIndexPath,'indexPathList.mat'),'newindexPathList');
    for i=1:length(newindexPathList)
        if strcmp(newindexPathList(i).indexPath,indexPath)
            isindexPathexisting = true;
            newindexPathList(i).indexPath = indexPath;
            break;
        else
            isindexPathexisting = false;
        end
    end
    if ~isindexPathexisting
        newindexPathList(length(newindexPathList)+1).indexPath = indexPath; %#ok<NASGU>
    end
else
    newindexPathList(1).indexPath = indexPath;
end
save (fullfile(mainIndexPath,'indexPathList.mat'),'newindexPathList');

%==========================================================================
function [downloadDir,dirname,isOverWrite] = createdownloadDir(indexPath,fileid,filename)
%CREATEDOWNLOADDIR  Create a directory name in the format [filename][fid].

dirname = strrep(strcat(strrep(filename{1},'.','_'),sprintf('%.0f',fileid)),'%20','_');
downloadDir = strrep(fullfile(indexPath,dirname),'%20',' ');
isdirExsting = isdir(downloadDir);

%by default do not overwrite a folder
isOverWrite = 'yes';

%If directroy already existing ask the user to Overwrite/Cancel?
if isdirExsting
    isOverWrite = questdlg('The Directory already exists. Do you want to Overwrite? ','Directory already existing','Ok','Cancel','Ok');
    %   ButtonName = questdlg('What is your favorite color?','Color Question','Red', 'Green', 'Blue', 'Green');
    if isempty(isOverWrite)
        isOverWrite = 'Cancel';
    end
    switch  lower(isOverWrite)
        case 'ok'
            cd ..
            rmdir(downloadDir,'s')
        case 'cancel'
            return
    end
end

%Create a Download directory
[status, message, mesageid] = mkdir(downloadDir);
%Return if there is any error in the directory creation
if status == 0
    error(mesageid, message);
end
%==========================================================================
function unzipfilenames = downloadfile(downloadFileURL,downloadDir,filename,fe)
%DOWNLOADFILE  Download a file.

%Download the file
if strcmp(fe{1},'.zip')
    %If zip file, unzip the file in download directory
    tempdownloadDir = fullfile(tempdir,'fxdownloads');
    mkdir(tempdownloadDir);
    [tempHtmlfile,status] = urlwrite(downloadFileURL,fullfile(tempdownloadDir,strcat(filename{1},'.html')));
    if isequal(status,1)
        unzip(tempHtmlfile, tempdownloadDir);
        delete(tempHtmlfile);
    else
        error('Error unzipping the URL')
    end
    dirlist = getsubdirs(tempdownloadDir);
    mfilecount=0;
    allfilecount = 0;
    for n=1:length(dirlist)
        allfiles = dir(dirlist{n});
        allfiles = allfiles(logical(~[allfiles.isdir]));
        if ~isempty(allfiles)
            for k=1:length(allfiles)
                allfilecount = allfilecount + 1;
                allunzipfiles{allfilecount} = fullfile(dirlist{n},allfiles(k).name);
            end
        end
    end
    dirfiles = tempdownloadDir;
    while true
        tempdirfiles = dir(dirfiles);
        if length(tempdirfiles) <= 3 && length(tempdirfiles(logical([tempdirfiles.isdir]))) >= 3
            for n = 1:length(tempdirfiles)
                if      ~strcmp(tempdirfiles(n).name(1),'.') && ...
                        ~strcmp(tempdirfiles(n).name,'.') && ...
                        ~strcmp(tempdirfiles(n).name,'..') && ...
                        tempdirfiles(n).isdir
                    tempdirfilename = tempdirfiles(n).name;
                end
            end
            dirfiles = fullfile(dirfiles,tempdirfilename);
        else
            break;
        end
    end
    [status,message,messageid] = copyfile(dirfiles,downloadDir,'f');
    for i=1:length(allunzipfiles)
        unzipfilenames(i) = strrep(strrep(allunzipfiles(i),dirfiles,downloadDir),'/','\');
    end
    %Return if there is any error in the directory moving
    if status == 0
        error(mesageid, message);
    end
    cd(tempdir);
    rmdir(tempdownloadDir,'s');
else
    %any file extension save the file in download directory
    urlwrite(downloadFileURL,fullfile(downloadDir,[filename{1} fe{1}]));
    unzipfilenames='';
end

%point to the download directory
cd(downloadDir);

%==========================================================================
function d = relevantHtmlInfo(htmlText,fileid,filename,dirname,downloadDir,contributorId,unzipfilenames)
%RELEVANTHTMLINFO  Get the relevant information in a structure.

d.dirname = dirname;
d.filename = filename;
d.title = regexp(htmlText,'<tr><td width=70% class=headercell height=20>&nbsp;(.*?)&nbsp;','tokens','once');
d.fullfilename = downloadDir;
d.description = strrep(regexprep(regexp(htmlText,'<td width="456" class="lnwrp">(.*?)</td>','tokens','once'),'\n','<br>'),'<br><br>','<br>');
%Category
category = regexp(htmlText,'objectType=Category">(.*?)</a>','tokens');
if ~isempty(category)
    d.category = regexprep(category{length(category)}{1},'[/,\s]','_');
else
    d.category = '';
end
categoryid = regexp(htmlText,'loadCategory\.do\?objectId=(\d+)&objectType=Category','tokens');
d.categoryurl = ['http://www.mathworks.com/matlabcentral/fileexchange/loadCategory.do?objectId=' categoryid{length(categoryid)}{1} '&objectType=Category'];
d.author = strrep(regexp(htmlText,['<a .*objectId=' contributorId{1} '">(.*?)</a>'],'tokens','once'),'&nbsp;','_');

d.authorurl = ['http://www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do?objectType=author&objectId=' contributorId{1}];
d.date = datenum(clock);
d.ratinglink = ['http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=' sprintf('%.0f',fileid) '&objectType=file#review_submission'];
d.link = strcat('http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=', sprintf('%.0f',fileid));

%Thumbnail url
thumbnailUrl = regexp(htmlText,'<td id="scrnshot" valign="top">.*imgName=(.*?)" onClick','tokens','once');
if ~isempty(thumbnailUrl)
    d.thumbnailUrl = strcat(['http://www.mathworks.com/matlabcentral/files/' sprintf('%.0f',fileid) '/'], thumbnailUrl{1});
else
    d.thumbnailUrl = '';
end
lastmoddate = regexp(htmlText,'<td width=100 valign="top">(.*?)<\/td>','tokens','once');
d.lastmoddate = lastmoddate;

%Finding Links Text
token = regexp(htmlText,'What are<br/>Published M-files.*\< <td height="15" colspan="2">(.*?)</td>','match');
if ~isempty(token)
    %Findig links
    fileurls = regexp(token{1},'(\w+)\.htm','match');
    %Finding Links Titles
    fileurlnames = regexp(token{1},'w.focus\();">(.*?)<','tokens');
    counter = 1;
    for j=1:length(unzipfilenames)
        x = regexp(unzipfilenames{j},'(\w+)\.htm','match');
        if ~isempty(x)
            for i=1:length(fileurls)
                if strcmp(x,fileurls{i})
                    d.fileurls{i} = unzipfilenames{j};
                    d.fileurlnames(i) = fileurlnames{i};
                end
            end
            counter=counter+1;
        end
    end
else
    d.fileurls = '';
    d.fileurlnames = '';
end

%==========================================================================
function writeIndex(indexPath,filename,downloadDir,intro,d)
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
s{end+1} = ['<a href="matlab: updatefxindex(''' fullfile(indexPath,filename) ''');" style="text-decoration:none"><b>Refresh</b></a>'];
s{end+1} = '</td>';
s{end+1} = '<td valign="middle" align="center" width="33%">';
[dirPath fxdirname] = fileparts(fileparts(indexPath));
if ~strcmp(fxdirname,'fxdownloads')
    s{end+1} = ['<a href="matlab: checkforUpdates(''' fullfile(indexPath,filename) ''',1);" style="text-decoration:none"><b>Check for Updates</b></a>'];
else
    s{end+1} =['<h3 align="center"><a href="matlab: fxgoup(''' fullfile(indexPath,filename) ''')" style="text-decoration:none" title="Go up one level">' ...
        '<img src="file:///' strrep(which('fxreturn.png'),'\','/') '"' ...
        ' style="border:0">My downloads</a>'];
    s{end+1} = '</h3>';
end
s{end+1} = '</td>';
s{end+1} = '<td valign="middle" align="right" width="33%">';
s{end+1} = ['<form method="post" action="matlab:fxsearch"><h3>Search: <input type="text" name="searchstr" value="">&nbsp;<input type="submit" value="Submit"><br>' ...
    '<a href="matlab: fxsearch(''recent'',15,1);" style="text-decoration:none;font-size:small">Top 15 recent files</a>, ' ...
    '<a href="matlab: fxsearch(''popular'',15,1);" style="text-decoration:none;font-size:small">Top 15 popular files</a>&nbsp;&nbsp;&nbsp;&nbsp;</h3></form>'];

s{end+1} = '</td>';
s{end+1} = '</tr>';
s{end+1} = '</table>';

s{end+1} = '<table cellspacing="0" class="t1" id="table2">';
s{end+1} = '<tr>';
s{end+1} = '<td valign="top" class="td1">';
%Thumbnail
if ~isempty(d.thumbnailUrl)
    s{end+1} = sprintf('<img src="%s" border="0" width="84" height="64">',d.thumbnailUrl);
else
    s{end+1} = '&nbsp;';
end
s{end+1} = '</td>';

s{end+1} = '<td valign="top" class="td1">';

% Title
if ~isempty(d.title)
    demotitle = d.title{1};
else
    demotitle = d.filename{1};
end
s{end+1} = sprintf('<h2><a href="%s">%s</a>', ...
    d.link,demotitle);
s{end+1} = sprintf('<font style="font-size:x-small">(<a href="matlab: addpath(''%s'')" style="text-decoration:none">addpath</a>)</font></h2>',downloadDir);
% Gray info line
s{end+1} = '<span class="dim"">';
% Author
if ~isempty(d.author{1})
    s{end+1} = sprintf('<a href="%s">%s</a>, ', ...
        d.authorurl,strrep(d.author{1},'_',' '));
end

%Category
if ~isempty(d.category)
    s{end+1} = sprintf('<a href="%s">%s</a>, ', ...
        d.categoryurl,d.category);
end
s{end+1} = sprintf('Updated on %s',datestr(d.date,0));
s{end+1} = '</span><br>';

%Local directory name
s{end+1} = '<span class="dim">';
s{end+1} = sprintf('CD to Local directory: <a href="matlab: cd(''%s'')">%s</a>, ',downloadDir,d.dirname);
s{end+1} = sprintf('<a href="matlab: web(''%s'')">Summary Page</a>',fullfile(downloadDir,'fxsummary.html'));
s{end+1} = '</span><br>';



%Related html links for a file
if ~isempty(d.fileurls)
    s{end+1} = '<p><ul>';
    for j=1:length(d.fileurls)
        s{end+1} = sprintf('<li><a href="file:///%s">%s</a></li>',strrep(d.fileurls{j},'\','/'), d.fileurlnames{j});
    end
    s{end+1} = '</p></ul>';

end
% Description
s{end+1} = '<br>';
if ~isempty(d.description)
    s{end+1} = d.description{1};
end

%Let the user Rate the downloaded file file
s{end+1} = ['<br><a href="' d.ratinglink '"><b>Review this file</b></a><br>'];
s{end+1} = '<br>';
if ~strcmp(fxdirname,'fxdownloads')
    s{end+1} = ['<a href="matlab: deletefile(''' downloadDir ''',1);" style="text-decoration:none"><b>Delete</b></a>'];
else
    s{end+1} = ['<a href="matlab: deletefile(''' downloadDir ''');" style="text-decoration:none"><b>Delete</b></a>'];
end
s{end+1} = '<br><br>';
s{end+1} = '</td>';
s{end+1} = '</tr>';
% Make web page
%Check if any file is downloaded. If downloaded sort the list according to
%the date and append it at the bottom.
allhtmllist = getallHtmlList(indexPath);
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

[fid,message] = fopen(fullfile(indexPath,filename),'w+');
if fid > 0
    for n = 1:length(s)
        fprintf(fid,'%s\n',s{n});
    end
    fclose(fid);
else
    error(message);
end
%Open the index file
%web([indexPath filename],'-new');
%==========================================================================
function createSummaryPage(indexPath,filename,downloadDir)
%CREATESUMMARYPAGE  Create a fxsummary.html page.

%Create a summary page for each individual download and save it in download
%directory of each downlaod
temp=[];
intro = '<h1><center>Summary</center></h1>';
temp{1} = '<html><head><title>File Exchange Downloads: Summary Page</title>';
% No margin above paragraphs in the description section.
temp{end+1} = '<link rel="stylesheet" href="http://www-internal.mathworks.com/devel/sharedemos/styles.css" type="text/css" />';
temp{end+1} = '</head>';
temp{end+1} = '<body>';

temp{end+1} = '<h3 align="right" STYLE="font-size:10pt;color:red">';
temp{end+1} = sprintf('Last Updated on: %s',datestr(clock,0));
temp{end+1} = '</h3>';

temp{end+1} = '<div class="main_intro">';
temp{end+1} = intro;
temp{end+1} = '</div>';

temp{end+1} = '<div>';
temp{end+1} =['<h3 align="center"><a href="matlab: fxgoup(''' fullfile(downloadDir,'fxsummary.html') ''')" style="text-decoration:none" title="Go up one level">' ...
    '<img src="file:///' strrep(which('fxreturn.png'),'\','/') '"' ...
    ' style="border:0">My downloads</a>'];
temp{end+1} = '</h3>';

[fid,message] = fopen(fullfile(indexPath,filename),'r');
if fid > 0
    htmlText = fread(fid,'char=>char')';
    fclose(fid);
else
    error(message);
end
token = regexp(htmlText,'(<table cellspacing="0" class="t1" id="table2">.*?</tr>)','match','once');
x = regexp(token,'deletefile(.*);','tokens','once');
y = regexprep(x{1},',1)',')');
temp{end+1} = strrep(token,x{1},y);
temp{end+1} = '</table>';

temp{end+1} = '<p>';

temp{end+1} = '</div></body></html>';


[fid,message] = fopen(fullfile(downloadDir,'fxsummary.html'), 'w+');
if fid > 0
    for i=1:length(temp)
        fprintf(fid,'%s\n',temp{i});
    end
    fclose(fid);
else
    error(message)
end

%==========================================================================

