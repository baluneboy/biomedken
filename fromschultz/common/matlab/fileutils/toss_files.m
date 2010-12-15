function toss_files(strPat)

% EXAMPLE
% strPat = '^mask_singleba_\w+\.img';
% toss_files(strPat);

[files,dirs] = spm_select('List',pwd,strPat);
casFiles = cellstr(files);
for i = 1:length(casFiles)
    strFile = casFiles{i};
    delete(strFile)
    fprintf('\nDeleted %s',strFile)
end