function casDirs = dirdeidentify(strTop)
blnSames = 0;
while ~all(blnSames)
    casDirs = dirdrill(strTop);
    numDirs = length(casDirs);
    blnSames = zeros(1,numDirs);
    for k = 1:numDirs
        strDir = casDirs{k};
        [strPath,strName,strExt] = fileparts(strDir);
        strName = [strName strExt];
        [strOut,strMessage] = deidentify(strPath,strName);
        if strcmp(strOut,strName)
            blnSames(k) = 1;
        else
            break
        end
    end
end