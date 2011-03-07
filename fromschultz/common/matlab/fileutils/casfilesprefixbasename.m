function casOut = casfilesprefixbasename(casFiles,strPrefix)

% EXAMPLE
% casFiles = {[];'c:\temp\swuaOne.img';'c:\temp\swuaTwo.img'};
% casOut = casfilesprefixbasename(casFiles,'d');

casOut = casFiles;
for i = 1:length(casFiles)
    strFile = casFiles{i};
    if isempty(strFile), continue; end
    [strPath,strName,strExt] = fileparts(strFile);
    strBase = [strPrefix strName strExt];
    casOut{i} = fullfile(strPath,strBase);
end
