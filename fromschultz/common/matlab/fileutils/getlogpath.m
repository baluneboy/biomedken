function strPath = getlogpath

% strPth = getlogpath
%
% See also getdatapath, getlogfilename

strPath = [getdatapath 'upper' filesep 'logs'];
if ~exist(strPath,'dir')
    error(sprintf('non-existing log dir path %s',strPath))
end
    