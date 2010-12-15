% CELLNANREPLACE replace all NaNs in a cell array with a value of your choice.
%
% ----------------------------------------------------------
% Input arguments:
%
% cellData - the cell array to be processed.
% replaceWith - will be placed instead of the NaN.
% ----------------------------------------------------------
% Output Arguments:
%
% cellData - the cell array to be returned;
% ----------------------------------------------------------
%
% Written by: Yoav Mor
% http://www.matlabgspot.com/
% http://www.yoavmor.com/
%



function cellData = cellnanreplace (cellData, replaceWith)
if ~(nargin==2)
    error (['function cellnanreplace does not take ',nargin,' arguments']);
end
if ~iscell(cellData)
    error (['first argument must be a cell array']);
end
setappdata (0,'cellReplaceWith',replaceWith); % we have to pass
% "replaceWith" somehow
% and the cellfun's
% function accepts one
% argument only.
% this is a work-around.
cellData = cellfun(@cellrep, cellData, 'UniformOutput',false);
rmappdata (0,'cellReplaceWith');              % clear the mess.

function value = cellrep (num)
replaceWith = getappdata (0,'cellReplaceWith'); % retrieve the value.

if isnan(num)
    % "isnan" can be replaced with different other conditions
    % if you need it to do something else other than this.
    value = replaceWith;
else
    value = num; % the original number back.
end