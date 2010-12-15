function somecellfun(strDirParent)

% SOMECELLFUN sample code for cellfun quick look
%
% EXAMPLE
% strDirParent = ''S:\data\upper\bci\screening\s1806bcis'';
% somecellfun(strDirParent)

cas = getsubdirs(strDirParent);

% Use a built-in function with cellfun and see what's what
casLongs = cellfun(@(x) x(length(x)>36), cas, 'UniformOutput',false);