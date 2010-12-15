function qsbat_writeeps(strFigDir,boolQuit);

strOldDir = pwd;
cd(strFigDir);

if ~strcmp(strFigDir(end),filesep)
   strFigDir = [strFigDir filesep];
end

% make a directory to store the figures
strEpsDir = strrep(strFigDir,['figures' filesep],['eps' filesep]);
if ~exist(strEpsDir)
   [statusVal,strMsg]=pimsmkdir(strEpsDir);
   if ~isempty(strMsg)
      fprintf('\npimsmkdir message for %s: %s\n',strEpsPath,strMsg)
   end
end

sDirList = dir('*.fig');


for i = 1:length(sDirList)
   strFigName = [strFigDir sDirList(i).name];
   hFig = hgload(strFigName);
   strEpsName = [strEpsDir strrep(sDirList(i).name,'.fig','.eps')];
   print('-depsc','-tiff','-r600',strEpsName,hFig);
   close(hFig);
end
cd(strOldDir);

if strcmp(boolQuit,'quit')
   quit;
end
