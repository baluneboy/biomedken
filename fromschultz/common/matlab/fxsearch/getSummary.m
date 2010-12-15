function temp = getSummary(allhtmllist)
%GETSUMMARY  Get the summary from all MATLAB Central File Exchange downloads.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Author : Santosh Kasula

temp = [];
filedata = [];
temp{1} = '';
counter = 1;
%If a summary file is existing in a download directory get the filename and
%download date from fread.
for i=1:length(allhtmllist)
    summaryfilename = allhtmllist{i};
    if ~isempty(summaryfilename)
        [currentdirpath currentdirname] = fileparts(fileparts(summaryfilename));
        filedata(counter).filename = summaryfilename;
        [fid,message] = fopen(summaryfilename,'r');
        if fid > 0
            htmlText = fread(fid,'char=>char')';
            fclose(fid);
        else
            error(message);
        end
        if ischar(htmlText)
            filedata(counter).date = datenum(regexp(htmlText,'Updated on (.*?)\s</span>','tokens','once'));
            olddirpath = regexp(htmlText,'<a href="matlab: deletefile\(''(.*?)\'');','tokens','once');
            olddirname = regexp(htmlText,'Local directory: <a href="matlab: cd\(.*?\)">(.*?)</a>','tokens','once');
            if ~isempty(olddirname) || ~isempty(olddirpath)
                if ~strcmp(olddirname,currentdirname) || ~strcmp(olddirpath,fileparts(summaryfilename))
                    htmlText = strrep(htmlText,olddirpath{1},fileparts(summaryfilename));
                    htmlText = strrep(htmlText,strrep(olddirpath{1},'\','/'), strrep(fileparts(summaryfilename),'\','/'));
                    htmlText = regexprep(htmlText,olddirname{1},currentdirname);
                    [fid,message] = fopen(summaryfilename,'w+');
                    if fid > 0
                        fprintf(fid,'%s\n',htmlText);
                        fclose(fid);
                    else
                        error(message);
                    end
                end
            end
        end
        counter = counter+1;
    end
end

if ~isempty(filedata)
    %check the paths if there are any multiple occurances
    [filename,i] = unique({filedata.filename});
    for n = 1:length(i)
        newfiledata(n) = filedata(i(n));
    end

    %Sort the list of downloads according to the date
    dateList = [newfiledata.date];
    [null,sortedDateIndexList] = sort(dateList);
    sortedDateIndexList = fliplr(sortedDateIndexList);
    newfiledata = newfiledata(sortedDateIndexList);

    %Get the summary in a variable.
    for n = 1:length(newfiledata)
        [fid,message] = fopen(newfiledata(n).filename,'r');
        if fid > 0
            htmlText = fread(fid,'char=>char')';
            fclose(fid);
        else
            error(message);
        end
        if ischar(htmlText) && ~isempty(htmlText)
            token = regexp(htmlText,'(<tr>.*</tr>)','match','once');
            temp{end+1} = token;
        end
    end
end
%==========================================================================









