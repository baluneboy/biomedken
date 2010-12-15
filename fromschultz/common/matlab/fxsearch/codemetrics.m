function varargout = codemetrics(workingDir)
%CODEMETRICS Generate code metrics for a directory
%   CODEMETRICS generates code metrics for the current directory and opens
%   a report in the help browser.
%
%   CODEMETRICS(D) generates metrics for the directory D.
%
%   METRICS = CODEMETRICS... returns the metrics as a structure instead of 
%   creating a report.
%
%   Example:
%     codemetrics('D:\Work')

% Pramod Kumar and Matthew Simoneau
% Copyright 2005-2006 The MathWorks, Inc.

% Default to the current directory.
if (nargin < 1)
    workingDir = pwd;
end

% Tunnel down the directory structure until we hit something.
directory = dir(workingDir);
while (length(directory) == 3) && all([directory.isdir])
    workingDir = [workingDir filesep directory(3).name];
    directory = dir(workingDir);
end

% Collect information about each file in the directory.
% try
stats = generateStats(workingDir);
% catch
%     disp(lasterr)
%     stats = struct('lines',{},'comments',{},'complexity',{},'help',{},'mlint',{},'clash',{},'clone',{});
% end

% Use the information to compute the metrics.
metrics = computeMetrics(stats);

% Return structure or show report.
if (nargout == 0)
    createReport(metrics,workingDir)
    varargout = {};
else
    varargout = {metrics};
end
