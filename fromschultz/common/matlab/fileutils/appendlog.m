function appendlog(strFile,strLine)

if ~exist(strFile,'file')
    error(sprintf('non-existing log file %s',strFile))
end

fid = fopen(strFile,'a');
fprintf('\n%s',strLine)
fprintf(fid,'\n%s',strLine);
fclose(fid);