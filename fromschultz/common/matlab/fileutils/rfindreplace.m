function res = rfindreplace(d, srchtxt, rplctxt, depth, results, file_exts)
% Function  RFINDREPLACE
%           a recursive function to find and replace files.   This is a very simple
%           function, and has by no means been written with efficiency in
%           mind, so it may run a little slow when the recursion has to go
%           to a great depth or if the search path contains relatively many
%           files.  YMMV.
%
% Inputs:   d - (string) filename or directory name to search
%           srchtxt (string) string text to find
%           rplctxt (string) string replacement string
%           depth (integer) value representing recursion depth (1 to start,
%                           -1 if no recursion is intended
%           results (array of strings) representing search results ([] empty to
%                                      start)
%           file_exts (array of strings) representing file extensions to
%                                        include in search
% Outputs:  res (array of strings) representing search results 
%
% Auth: Matthias Beebe
%
% Last Modified:  3/07
%
recurse = 1;

if(nargin < 2)
    printusage;
    return;
end

switch (nargin)
    case 2
        depth = 1;
        rplctxt = -1;
        results = {};
        file_exts = [];
    case 3
        depth = 1;
        results = {};
        file_exts = [];
    case 4
        results = {};
        if(depth < 0)
            recurse = 0;
        end
        file_exts = [];
    case 5
        if(depth < 0)
            recurse = 0;
        end
        file_exts = [];
    otherwise % all parameters given
        if(depth < 0)
            recurse = 0;
        end
end

if(isdir(d))
    if(strcmp(fileparts(d),'') == 1)
        d = fullfile(pwd, d);
    end
elseif(exist(d, 'file')) % not a dir
    %get file extension of d
    file_ext = [];
    ext_match = [];
    i = findstr('.', d);
    if(~isempty(i))
        file_ext = d(i(length(i)):length(d));
    end
    % look for file extension in list of file exts
    if((~isempty(file_exts)) && (~isempty(file_ext)))
        ext_match = strmatch(file_ext, file_exts,'exact');
    end
    if((~isempty(ext_match)) || (isempty(file_exts)))
        [resultstruct, success] = findreplace(d, srchtxt, rplctxt);
        results = buildresults(resultstruct, depth, results);        
    end
    res = results;
    return;
end

files = dir(d);

for i = 1:length(files)

    % skip file if it is the current dir or parent
    if(strcmp(files(i).name, '.') == 1 || strcmp(files(i).name, '..') == 1)
        continue;
    end

    spacestr = '';
    for j = 1:(depth-1)
        %fprintf(1, '     ');
        spacestr = ['     ' spacestr];
    end
    %fprintf(1, '%s\n', files(i).name);
    results = rprintf([spacestr files(i).name], results);

    % if is a directory and 'recurse' is true, recurse, or if it is just a file recurse
    if((files(i).isdir == 1 && recurse == 1) || files(i).isdir == 0)
        results = rfindreplace([d filesep files(i).name],srchtxt, rplctxt, depth + 1, results, file_exts);
    end
end

res = results;


function res = rprintf(str, results)

res = [results; str];


function results = buildresults(resultstruct, depth, results)
% construct strings (results) array from result structure
spacestr = '';
for j = 1:depth
    spacestr = ['   ' spacestr];
end

for k = 1:length(resultstruct.line_nums);
    line_num = resultstruct.line_nums(k);
    %for j = 1:depth fprintf(1, '     '); end
    line = strtrim(resultstruct.lines{line_num});
    %fprintf(1, '%d: %s\n',  line_num, line);
    results = rprintf(['   ' spacestr num2str(line_num) ': ' line], results);
end


function printusage()
fprintf('Usage:  rfindreplace(dir/file, search_str, <repstr>, <depth>, <results> <file_exts>)\n');
fprintf('   eg: >>rfindreplace(\''.\'', \''fid\'', -1, -1, {}, strvcat(\''.m\''))\n');
fprintf('   or: >>rfindreplace(\''.\'', \''fid\'', -1, 1, {}, strvcat(\''.txt\'', \''.m\''))\n');


