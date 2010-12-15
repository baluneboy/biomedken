function strFile = getlogfilename(strMfile,strExt,strHeaderLine)

% strFile = getlogfilename(strMfile,strExt,strHeaderLine)
%
% See also getlogpath, getdatapath


if ~strcmp(strExt(1),'.')
    strExt = ['.' strExt];
end

strLogpath = getlogpath;
strFile = fullfile(strLogpath,[strMfile strExt]);
if ~exist(strFile,'file')
    fid = fopen(strFile,'w');
    fprintf(fid,'%s',strHeaderLine);
    fclose(fid);
    fprintf('\nCreated file %s with header: %s\n',strFile,strHeaderLine)
end