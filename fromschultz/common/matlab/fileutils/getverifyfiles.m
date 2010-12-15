function casFile = getverifyfiles(strPattern,strDir,strType,rng)

% EXAMPLE
% strPattern = '.*_0{1,2}[1,2]\.img$';
% strDir = 'C:\temp\fmri_testing\c1317plas_control\study_20050909\series_10_bas_MoCoSeries';
% strType = 'cas';
% rng=1:4; % from one thru four files expected
% casFiles = getverifyfiles(strPattern,strDir,strType,rng)

casFile = getpatternfiles(strPattern,strDir,strType);
if ~verifyfilecount(casFile,strType,rng)
    error('unexpected file count')
end