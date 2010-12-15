function metrics = computeMetrics(stats)
%computeMetrics Generate the statistics.
%   computeMetrics(STATS) takes structure of file stats and returns a
%   structure of metrics.
%
%   Example:
%     stats = generateStats(pwd);
%     metrics = computeMetrics(stats);
%     createReport(metrics,pwd)

% Pramod Kumar and Matthew Simoneau
% Copyright 2005-2006 The MathWorks, Inc.

% Header.
S = {};
S{end+1} = sectionTitle('Detailed Metrics');
S{end+1} = sprintf('<table class="datatable" cellpadding="0" cellspacing="0">\n');
S{end+1} = sprintf('\t<tr>\n');
S{end+1} = sprintf('\t\t<th>Filename</th>\n');
S{end+1} = sprintf('\t\t<th>Line Count</th>\n');
S{end+1} = sprintf('\t\t<th>Percent Comments</th>\n');
S{end+1} = sprintf('\t\t<th>Cyclomatic Complexity</th>\n');
S{end+1} = sprintf('\t\t<th>M-Lint Messages</th>\n');
S{end+1} = sprintf('\t\t<th>Help Warnings</th>\n');
S{end+1} = sprintf('\t\t<th>Filename Clashes</th>\n');
S{end+1} = sprintf('\t\t<th>Cloned Code</th>\n');
S{end+1} = sprintf('\t</tr>\n');

% A row for each file.
for i = 1:size(stats)
    S{end+1} = sprintf('\t<tr>\n');
    S{end+1} = tableData('%s',stats(i).filename);
    S{end+1} = tableData('%d',stats(i).lines);
    S{end+1} = tableData('%.0f%%',100*stats(i).comments/stats(i).lines);
    S{end+1} = tableData('%d',stats(i).complexity);
    S{end+1} = tableData('%d',stats(i).mlint,['mlint_' stats(i).name],true);
    S{end+1} = tableData('%d',stats(i).help,['help_' stats(i).name],true);
    S{end+1} = tableData('%d',stats(i).clash,['clash_' stats(i).name],true);
    S{end+1} = tableData('%d',stats(i).clone,['clone_' stats(i).name],true);
    S{end+1} = sprintf('</tr>\n');
end
S{end+1} = '</table>';

% Other tables.
S = [S generateMlintReportTable(stats)];
S = [S generateHelpReportTable(stats)];
S = [S generateClashReportTable(stats)];
S = [S generateCloneTable(stats)];

% Convert the cell array of details into a long char array.
S{end+1} = sprintf('\n');
[rows,cols] = size(S);
details = '';
for i = 1:rows
    for j = 1:cols
        details = [details S{i,j}];
    end
end

% Store everything in the output structure.
metrics = [];
if (numel(stats) == 0)
    metrics.complexity = NaN;
    metrics.mlint = NaN;
    metrics.comments = NaN;
    metrics.help = NaN;
    metrics.clash = NaN;
    metrics.clone = NaN;
    metrics.details = '';
else
    metrics.complexity = max([stats.complexity NaN]);
    metrics.mlint = mean([stats.mlint]);
    metrics.comments = mean([stats.comments]/[stats.lines]);
    metrics.help = mean([stats.help]);
    metrics.clash = sum([stats.clash]);
    metrics.clone = sum([stats.clone]);
    metrics.details = details;
end

%==========================================================================
function str = tableData(format,value,link,blankZero)
%tableData Format one <td>.

if (nargin >= 4) && blankZero && (value == 0)
    format = '&nbsp;';
    link = '';
end
if (nargin >= 3) && ~isempty(link)
    str = sprintf(['\t\t<td href="#%s">' format '</td>\n'],link,value);
else
    str = sprintf(['\t\t<td>' format '</td>\n'],value);
end

%==========================================================================
function mlintInfo = generateMlintReportTable(stats)
%This function generates the Mlint report in a table format
%get a listing of all files

mlintInfo = {};
mlintInfo{end+1} = sectionTitle('M-Lint Messages');
table = {};
backgroundColor = false;
for i = 1:numel(stats)
    messages = stats(i).mlintmessages;
    MessageNum = numel(messages);
    for j = 1:MessageNum
        if backgroundColor
            table{end+1} = sprintf('\t<tr class="odd">\n');
        else
            table{end+1} = sprintf('\t<tr>\n');
        end
        table{end+1} = sprintf('\t\t<td align="left"><a name="mlint_%s"></a>%s</td>', stats(i).name,stats(i).filename);
        table{end+1} = sprintf('\t\t<td align="left">%d</td>\n',messages(j).line(1));
        %table{end+1} = sprintf('\t\t<td align="left">%d</td>\n',messages(j).column(1));
        table{end+1} = sprintf('\t\t<td align="left">%s</td>\n',escapeHtml(messages(j).message));
        table{end+1} = sprintf('\t</tr>\n');
    end
    if (MessageNum > 0)
        backgroundColor = ~backgroundColor;
    end
end

if isempty(table)
    mlintInfo{end+1} = 'There are no M-lint messages.';
else
    mlintInfo{end+1} = sprintf('<table class="datatable" cellpadding="0" cellspacing="0">\n');
    mlintInfo{end+1} = sprintf('\t<tr>\n');
    mlintInfo{end+1} = sprintf('\t\t<th align="left">Filename</th>\n');
    mlintInfo{end+1} = sprintf('\t\t<th align="left">Line</th>\n');
    %mlintInfo{end+1} = sprintf('\t\t<th align="left">Column</th>\n');
    mlintInfo{end+1} = sprintf('\t\t<th align="left">Message</th>\n');
    mlintInfo{end+1} = sprintf('\t</tr>\n');
    mlintInfo = [mlintInfo table];
    mlintInfo{end+1} = '</table>';
end

%==========================================================================
function s = generateHelpReportTable(stats)
%This function generates the Mlint report in a table format
%get a listing of all files

s = {};
s{end+1} = sectionTitle('Help Warnings');

table = {};
for i = 1:length(stats)
    if (stats(i).help > 0)
        table{end+1} = sprintf('\t<tr>\n');
        table{end+1} = sprintf('\t\t<td align="left"><a name="help_%s"></a>%s</td>',stats(i).name,stats(i).filename);
        table{end+1} = sprintf('<td>');
        needsComma = false;
        if isempty(stats(i).helpmessages.help)
            table{end+1} = 'no help';
            needsComma = true;
        end
        if isempty(stats(i).helpmessages.description)
            if needsComma
                table{end+1} = ', ';
            end
            table{end+1} = 'no description';
            needsComma = true;
        end
        if isempty(stats(i).helpmessages.example)
            if needsComma
                table{end+1} = ', ';
            end
            table{end+1} = 'no example';
        end
        table{end+1} = sprintf('\t</td>\n');
        table{end+1} = sprintf('\t</tr>\n');
    end
end

if isempty(table)
    s{end+1} = 'There are no help warnings.';
else
    s{end+1} = sprintf('<table class="datatable" cellpadding="0" cellspacing="0">\n');
    s{end+1} = sprintf('\t<tr>\n');
    s{end+1} = sprintf('\t\t<th align="left">Filename</th>\n');
    s{end+1} = sprintf('\t\t<th align="left">Message</th>\n');
    s{end+1} = sprintf('\t</tr>\n');
    s = [s table];
    s{end+1} = '</table>';
end

%==========================================================================
function s = generateClashReportTable(stats)
%GENERATECLASHREPORTTABLE generates the Mlint report in a table format.
%   y = GENERATECLASHREPORTTABLE(dirname) returns a cell array which has
%   the clash information in the form of a table

s = {};
s{end+1} = sectionTitle('Filename Clashes');

table = {};
for i = 1:length(stats)
    if (stats(i).clash > 0)
        table{end+1} = sprintf('\t<tr>\n');
        table{end+1} = sprintf('\t\t<td align="left"><a name="clash_%s"></a>%s</td>\n',stats(i).name,stats(i).filename);
        table{end+1} = sprintf('\t\t<td>%s</td>\n',stats(i).clashname);
        table{end+1} = sprintf('\t</tr>\n');
    end
end

if isempty(table)
    s{end+1} = 'There are no reported clashes.';
else
    s{end+1} = sprintf('<table class="datatable" cellpadding="0" cellspacing="0">\n');
    s{end+1} = sprintf('\t<tr>\n');
    s{end+1} = sprintf('\t\t<th align="left">Filename</th>\n');
    s{end+1} = sprintf('\t\t<th align="left">Clashing Function</th>\n');
    s{end+1} = sprintf('\t</tr>\n');
    s = [s table];
    s{end+1} = '</table>';
end

%==========================================================================
function s = generateCloneTable(stats)
%This function generates the cut and paste table to be included in the main
%report.

s = {};
s{end+1} = sectionTitle('Cloned Code');

table = {};
for i = 1:numel(stats)
    for j = 1:numel(stats(i).cloneInfo)
        cloneInfo = stats(i).cloneInfo(j);
        table{end+1} = sprintf('\t<tr>\n');
        table{end+1} = sprintf('\t\t<td><a name = "clone_%s">%d</a></td>', ...
            stats(i).name, cloneInfo.end1 - cloneInfo.start1);
        table{end+1} = sprintf('\t\t<td>%s</td>\n',cloneInfo.file1);
        table{end+1} = sprintf('\t\t<td>%d-%d</td>\n',cloneInfo.start1,cloneInfo.end1);
        table{end+1} = sprintf('\t\t<td>%s</td>\n',cloneInfo.file2);
        table{end+1} = sprintf('\t\t<td>%d-%d</td>\n',cloneInfo.start2,cloneInfo.end2);
        table{end+1} = sprintf('\t\t</tr>\n');
    end
end

if ~ispc && ~strcmp(computer,'GLNX86')
    s{end+1} = 'Cloned code metrics are only available on the PC and Linux.';
elseif isempty(table)
    s{end+1} = 'There are no sections of cloned code detected.';
else
    s{end+1} = sprintf('<table class="datatable" cellpadding="0" cellspacing="0">\n');
    s{end+1} = sprintf('\t<tr>\n');
    s{end+1} = sprintf('\t\t<th align="left">Number of Lines</th>\n');
    s{end+1} = sprintf('\t\t<th align="left">Filename</th>\n');
    s{end+1} = sprintf('\t\t<th align="left">Lines</th>\n');
    s{end+1} = sprintf('\t\t<th align="left">Filename</th>\n');
    s{end+1} = sprintf('\t\t<th align="left">Lines</th>\n');
    s{end+1} = sprintf('\t</tr>\n');
    s = [s table];
    s{end+1} = sprintf('</table>\n');
end

%==========================================================================
function s = sectionTitle(title)
link = strrep(title,' ','_');
s = sprintf('<h2><a name="%s"></a>%s</h2>\n',link,title);

%==========================================================================
function s = escapeHtml(s)
s = strrep(s,'&','&amp;');
s = strrep(s,'<','&lt;');
s = strrep(s,'>','&gt;');
