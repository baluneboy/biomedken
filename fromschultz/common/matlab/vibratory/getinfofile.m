function strInfoFilename=getinfofile(strInfoPath,strSensorID,strTag,strFs);

strLongPath=[strInfoPath strSensorID filesep 'padspec' filesep strTag filesep];
sDir=dir([strLongPath 'm*' strTag '*' strFs '*info.m']);
if length(sDir)==1
   strInfoFilename=[strLongPath sDir.name];
   return
end

strInfoPath=strInfoPath(1:end-6);
sDir=dir([strInfoPath '*' strSensorID '*' strTag strFs '*info.mat']);
if length(sDir)==1
   strInfoFilename=[strInfoPath sDir.name];
   return
end

sDir=dir([strInfoPath '*' strSensorID '*' strTag '*info.m']);
if length(sDir)==1
   strInfoFilename=[strInfoPath sDir.name];
else
	error('num of info files must be exactly 1')
end

return

if 1
	error('should not have gotten to this obsolete segment of code')
else
   clear sDir
   isep=findstr(strInfoPath,filesep);
   strResultsPath=[strInfoPath(1:isep(end-2)) strSensorID filesep];
   sDir=dir([strResultsPath '*' strTag '*info.m']);
   if length(sDir)==1
      % NO, THIS CAUSES PROBLEMS
      if 0
         if isunix
            strCopyCmd=['cp ' strResultsPath sDir.name ' ' strInfoPath];
         else
            strCopyCmd=['copy "' strResultsPath sDir.name '" "' strInfoPath '"'];
         end
         [s,w]=unix(strCopyCmd);
         strInfoFilename=[strInfoPath sDir.name];
      end
   elseif length(sDir)>1
      iMatch=[];
      for i=1:length(sDir)
         str=sDir(i).name;
         iTag=findstr(str,strTag);
         if ( (strcmp(str(iTag-1),'+') | strcmp(str(iTag-1),'-')) & ismember(str(iTag+length(strTag)),'0123456789') )
            iMatch=[iMatch i];
         end
      end
      if length(iMatch)==1
         strInfoFilename=[strResultsPath sDir(iMatch).name];
      elseif length(iMatch)>1
         disp('interactive dialog in getinfofile.m for info file is about to launch')
         str = {sDir.name};
         [s,v]=listdlg('PromptString','Select a file:','SelectionMode','single','ListString',str);
         strInfoFilename=[strInfoPath sDir(s).name];
      else
         error('num of info mat files must be exactly 1')
      end
   end
end
