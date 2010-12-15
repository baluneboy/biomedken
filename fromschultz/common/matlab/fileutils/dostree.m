function dostree(strDir,strFile)

% EXAMPLE
% strDir = 'C:\data\fmri\adat\c1321plas\pre\study_20060720\series_12_shoulder_bas_MoCoSeries';
% strFile = 'testing';
% dostree(strDir,strFile);

strFileOut = fullfile(strDir,[strFile '_tree.txt']);
[foo,str] = dos(['tree /F /A ' strDir]);
fid = fopen(strFileOut,'w');
fprintf(fid,'%s\n',datestr(now));
fprintf(fid,'%s',str);
fclose(fid);