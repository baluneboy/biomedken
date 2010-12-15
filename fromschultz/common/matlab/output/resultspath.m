function [strPath,strUnique]=resultspath(sOutput,sHeader,strPlotType,strComment);

%resultspath - assign unique name (and path) used in batch processing
%
%[strPath,strUnique]=resultspath(sOutput,sHeader,strPlotType,strComment);
%
%Inputs: sOutput - structure of output parameters
%        sHeader - structure of header info
%        strPlotType - string for m-file that called this routine
%        strComment - string for comment
%
%Outputs: strPath - string for full path to 
%Author: Ken Hrovat, 3/22/2001
%$Id: resultspath.m 4160 2009-12-11 19:10:14Z khrovat $

[strPath,strUnique,strExt,strVer]=fileparts(tempname);
strShort=locShorten(strComment,9);
strUnique=[strShort '_' strUnique];
if isfield(sOutput,'ResultsPath')
   strResultsPath=sOutput.ResultsPath;
else
   try
      s=get(0,'UserData'); % may have sUser stashed here
      sUser=s.sUser;
      strResultsPath=sUser.strResultsPath;
   catch
      strErr=['Caught error: ' get(0,'ErrorMessage')];
      strResultsPath=tempdir;
      fprintf('\n%s\n... so using %s for results path.\n',strErr,strResultsPath)
   end
end

strPath=[strResultsPath sHeader.SensorID filesep strPlotType filesep strUnique filesep];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function strShort=locShorten(strComment,n);
strShort=strComment(find(isletter(strComment)));
len=min([length(strShort) n]);
strShort=strShort(1:len);