function [strParent,strSelf] = dirparent(str)
str = fixpath(str);
[strPath,strName,strExt,strVer] = fileparts(str);
strSelf = locGetSelf(strName,strExt);
if isdir(str) | (exist(str,'file') == 2)
    strParent = fixpath(strPath);
else
    error(sprintf('input %s is not a file or directory',str))
end

% -------------------------------------------
function strSelf = locGetSelf(strName,strExt)
if isempty(strExt)
    strSelf = strName;
else
    strSelf = [strName '.' strExt];
end