function strOut = cygpath(strIn)

% EXAMPLE
% strIn = '/cygdrive/c/data/fmri/adat/c1316plas/pre/study_20060608/series_06_shoulder_bas_MoCoSeries/_series_structure_shoulder.mat';
% strOut = cygpath(strIn)

strCmd = ['c:\cygwin\bin\cygpath -w ' strIn];
[foo,strOut] = dos(strCmd);
strOut = deblank(strOut);