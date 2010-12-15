function spssappendscript(strVar)
% see spsscorrappendscript.m
fid = fopen('c:\temp\trash_spssappendscript.SPS','a');
fprintf(fid,'%s',locSPSS(strVar));
fclose(fid);

%-----------------------------
function str = locSPSS(strVar)
str = sprintf('\nREGRESSION');
str = sprintf('%s\n  /DESCRIPTIVES MEAN STDDEV CORR SIG N',str);
str = sprintf('%s\n  /MISSING LISTWISE',str);
str = sprintf('%s\n    /STATISTICS COEFF OUTS CI BCOV R ANOVA COLLIN TOL CHANGE ZPP',str);
str = sprintf('%s\n    /CRITERIA=PIN(.05) POUT(.10)',str);
str = sprintf('%s\n    /NOORIGIN',str);
str = sprintf('%s\n    /DEPENDENT %s',str,strVar);
str = sprintf('%s\n    /METHOD=ENTER mmtPre fugl_meyerPre amat_timePre mod_ashworthPre .',str);