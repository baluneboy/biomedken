function rename1970files(strPath,strFilenamewild);

%renamecopy1970files(strPath,strFilenamewild);

[filenames,direc]=dirdeal([strPath strFilenamewild]);

for i=1:length(filenames)
   strFilename=filenames{i};
   strPIMSfilename=convert1970filename(strFilename);
   fprintf('\n%s TO %s',strFilename,strPIMSfilename)
   fprintf('\n%s TO %s',[strFilename '.header'],[strPIMSfilename '.header'])
   %strCmd=['!copy ' strPath strFilename ' ' strPath strPIMSfilename];
   %eval(strCmd);
   %strCmd=['!copy ' strPath strFilename '.header ' strPath strPIMSfilename '.header'];
   %eval(strCmd);
end