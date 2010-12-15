function spsscorrappendscript(strVar)
%EXAMPLE
% casRois = {'roi01_primary_motor_ba4',...
% 'roi02_primary_sensory_ba3',...
% 'roi03_somatosensory_ba4y3y1y2',...
% 'roi04_premotor_ba6',...
% 'roi05_prefrontal_ba8y9',...
% 'roi06_supplementary_motor_ba4y6',...
% 'roi07_anterior_cingulate_gyrus_ba24',...
% 'roi08_posterior_parietal_region_ba39y40',...
% 'roi11_lateral_premotor_fromafni',...
% 'roi12_sma_presma_fromafni',...
% 'roi13_primary_motor_cortex_fromafni',...
% 'roi14_somatosensory_ba3y1y2',...
% 'roi98_mniwholebrain_fromspm'};
% cellfun(@spsscorrappendscript,casRois)

% fid = fopen('c:\temp\trash_spssappendscript2.SPS','a');
% fprintf(fid,'%s',locSPSSCORR(strVar));
fid = fopen('c:\temp\trash_spssappendscript4AMATshoulder.SPS','a');
fprintf(fid,'%s',locSPSSCORR4AMAT('shoulder',strVar));
fclose(fid);
fid = fopen('c:\temp\trash_spssappendscript4AMATwrist.SPS','a');
fprintf(fid,'%s',locSPSSCORR4AMAT('wrist',strVar));
fclose(fid);

%---------------------------------
function str = locSPSSCORR4AMAT(strTask,strVar)
str = sprintf('\nUSE ALL.');
str = sprintf('%s\nCOMPUTE filter_$=(task = "%s" & roi = "%s").',str,strTask,strVar);
str = sprintf('%s\nVARIABLE LABEL filter_$ ''task = ""%s"" & roi = ""%s"" (FILTER)''.',str,strTask,strVar);
str = sprintf('%s\nVALUE LABELS filter_$ 0 ''Not Selected'' 1 ''Selected''.',str);
str = sprintf('%s\nFORMAT filter_$ (f1.0).',str);
str = sprintf('%s\nFILTER BY filter_$.',str);
str = sprintf('%s\nEXECUTE.',str);
str = sprintf('%s\nCORRELATIONS',str);
str = sprintf('%s\n    /VARIABLES=postpreAMAT postprePctEXTinv postprePctEXTuninv',str);
str = sprintf('%s\n    /PRINT=TWOTAIL NOSIG',str);
str = sprintf('%s\n    /STATISTICS DESCRIPTIVES',str);
str = sprintf('%s\n    /MISSING=PAIRWISE.',str);

%---------------------------------
function str = locSPSSCORR(strVar)
str = sprintf('\nUSE ALL.');
str = sprintf('%s\nCOMPUTE filter_$=(roi = "%s").',str,strVar);
str = sprintf('%s\nVARIABLE LABEL filter_$ ''roi = ""%s"" (FILTER)''.',str,strVar);
str = sprintf('%s\nVALUE LABELS filter_$ 0 ''Not Selected'' 1 ''Selected''.',str);
str = sprintf('%s\nFORMAT filter_$ (f1.0).',str);
str = sprintf('%s\nFILTER BY filter_$.',str);
str = sprintf('%s\nEXECUTE.',str);
str = sprintf('%s\nCORRELATIONS',str);
str = sprintf('%s\n    /VARIABLES=preAMAT InvPctExtra UninvPctExtra',str);
str = sprintf('%s\n    /PRINT=TWOTAIL NOSIG',str);
str = sprintf('%s\n    /STATISTICS DESCRIPTIVES',str);
str = sprintf('%s\n    /MISSING=PAIRWISE.',str);
% %SHOULD END UP LOOKING LIKE THIS:
% USE ALL. 
% COMPUTE filter_$=(roi = "roi02_primary_sensory_ba3"). 
% VARIABLE LABEL filter_$ 'roi = ""roi02_primary_sensory_ba3"" (FILTER)'. 
% VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'. 
% FORMAT filter_$ (f1.0). 
% FILTER BY filter_$. 
% EXECUTE. 
% CORRELATIONS 
%   /VARIABLES=preAMAT InvPctExtra UninvPctExtra 
%   /PRINT=TWOTAIL NOSIG 
%   /STATISTICS DESCRIPTIVES 
%   /MISSING=PAIRWISE.