function strFile = findexactlyonefile(strPat,strDir)

%EXAMPLE
% strPat = '^roi99_wholecube_both_p-overlay\.img$';
% strDir = 'C:\data\fmri\adat\c1318plas\pre\study_20050909\series_11_wrist_bas_MoCoSeries';
% strFile = findexactlyonefile(strPat,strDir);  %e.g. 'C:\data\fmri\adat\c1318plas\pre\study_20050909\series_11_wrist_bas_MoCoSeries\roi99_wholecube_both_p-overlay.img';

casFiles = getpatternfiles(strPat,strDir,'cas');
if numel(casFiles) ~= 1
    error('daly:fmri:getpatternfilesCount','expected exactly one match for "%s" in "%s", but found %d',strPat,strDir,numel(casFiles));
end
strFile = casFiles{1};