function [strLogPath,strResultsPath,strUnique]=logresultspath(sOutput,sHeader,strPlotType,strComment);

%logresultspath - assign unique name (and path) used in batch processing
%
%[strResultsPath,strUnique]=logresultspath(sOutput,sHeader,strPlotType,strComment);
%
%Inputs: sOutput - structure of output parameters
%        sHeader - structure of header info
%        strPlotType - string for m-file that called this routine
%        strComment - string for comment
%
%Outputs: strResultsPath - string for full path to results
%Author: Ken Hrovat, 3/22/2001
%$Id: logresultspath.m 4160 2009-12-11 19:10:14Z khrovat $

[strResultsPath,strUnique,strExt,strVer]=fileparts(tempname);
strShort=locShorten(strComment,9);
strUnique=[strShort '_' strUnique];

% Lumped log path
strLogPath=locGetPath('LogPath',sOutput);

% Long results path
strResultsTrunk=locGetPath('ResultsPath',sOutput); % just trunk
[iLeft,iRight,strIncrement]=finddelimited(':',',',sHeader.ISSConfiguration,1);
if isempty(strIncrement)
   strIncrement='inc00';
else
   strIncrement=sprintf('inc%02d',str2num(strIncrement));
end
strResultsPath=[strResultsTrunk strIncrement filesep sHeader.SensorID filesep strPlotType filesep strUnique filesep];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strPath=locGetPath(strField,sOutput);
if isfield(sOutput,strField)
   strPath=getfield(sOutput,strField);
else
   try
      s=get(0,'UserData'); % may have sUser stashed here
      sUser=s.sUser;
      strPath=getfield(sUser,strField);
   catch
      strErr=['Caught error: ' get(0,'ErrorMessage')];
      strPath=tempdir;
      fprintf('\n%s\n... so using %s for %s.\n',strErr,strPath,strField)
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strShort=locShorten(strComment,n);
strShort=strComment(find(isletter(strComment)));
len=min([length(strShort) n]);
strShort=strShort(1:len);