function gaitcsvwrite(strFile,cas,m)

% EXAMPLE
% strFile = 'c:\temp\test.csv';
% cas = {'one','two','three','4','5','6','7','eight','nine','x','11','dozen'};
% m = randn(7,12);
% gaitcsvwrite(strFile,cas,m)

fid = fopen(strFile,'w');
for i = 1:length(cas)
    str = cas{i};
    fprintf(fid,'%s,',str);
end
fprintf(fid,'\n')
numCols = size(m,2);
strFmt = [repmat('%.4f,',1,numCols) '\n'];
fprintf(fid,strFmt,m);
fclose(fid);
