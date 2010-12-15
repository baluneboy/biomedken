function createReport(metrics,title,file)
%createReport Generate the report and open it in the web browser.
%   createReport(METRICS,TITLE) creates the report and opens it up in the
%   browser.
%
%   createReport(METRICS,TITLE,FILE) writes the report to FILE.
%
%   Example:
%     stats = generateStats(pwd);
%     metrics = computeMetrics(stats);
%     createReport(metrics,pwd)

% Pramod Kumar and Matthew Simoneau
% Copyright 2005-2006 The MathWorks, Inc.

% Argument parsing.
if (nargin < 2)
    title = '';
end

% Read the template.
thisDir = fileparts(mfilename('-fullpath'));
c = file2char(fullfile(thisDir,'private','template'));

% Stick the data into the template.
c = strrep(c,'$$TITLE$$',title);
c = strrep(c,'$$DATE$$',datestr(now,'yyyy-mm-dd'));
c = strrep(c,'$$complexity$$',sprintf('%.0f',metrics.complexity));
c = strrep(c,'$$mlint$$',sprintf('%.1f',metrics.mlint));
c = strrep(c,'$$comments$$',sprintf('%.1f',metrics.comments));
c = strrep(c,'$$help$$',sprintf('%.1f',metrics.help));
c = strrep(c,'$$clash$$',sprintf('%.0f',metrics.clash));
c = strrep(c,'$$clone$$',sprintf('%.0f',metrics.clone));
c = strrep(c,'$$details$$',metrics.details);

% Write the report.
if (nargin < 3)
    file = [tempname '.html'];
end
f = fopen(file,'w');
fprintf(f,'%s',c);
fclose(f);

% Open the report in the browser.
if (nargin < 3)
    web(file,'-browser')
end

%==========================================================================
function c = file2char(filename)
f = fopen(filename);
c = native2unicode(fread(f,'uint8=>uint8')');
fclose(f);
