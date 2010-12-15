function example_matlab_pivot_table(strFileXLS)

% EXAMPLE
% strFileXLS = 'C:\Program Files\MATLAB\R2010a\toolbox\stats\hospital.xls';
% example_matlab_pivot_table(strFileXLS);

strFileOUT = strrep(strFileXLS,'.xls',['_' datestr(now,30) '_pivot.xls']);
d = dataset('XLSFile',strFileXLS,'ReadObsNames',true);
mw = grpstats(d,{'sex' 'smoke'},{'mean','sem'},'datavars','wgt');
export(mw,'XLSfile',strFileOUT);
fprintf('\n\n%s\n',strFileOUT)
