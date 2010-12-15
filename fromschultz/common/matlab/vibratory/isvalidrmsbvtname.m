function [blnValid,fc,str]=isvalidrmsbvtname(strFilename);

% isvalidrmsbvtname - checks for expected filename convention
%
% Valid form: rmsbvt_CUTOFF_STRING.m
% where CUTOFF is strrep(sprintf('%06.2f',fc),'.','p')
% and STRING is unique string (without underscores)
%
%[blnValid,fc,str]=isvalidrmsbvtname(strFilename);
%
%Input: strFilename - string for m-filename with/out path
%
%Outputs: blnValid - boolean true if valid name
%         fc - scalar for cutoff frequency derived from name
%         str - string for unique identifier

% written by:  Ken Hrovat on 3/20/2001
% $Id: isvalidrmsbvtname.m 4160 2009-12-11 19:10:14Z khrovat $

% Initialize
blnValid=0;
fc=[];
str='';

[strPath,strName,strExt,strVer]=fileparts(strFilename);

% Quick checks
blnQuick=ischar(strName) & (size(strName,1) == 1) & strncmp(lower(strName),'rmsbvt_',7);

if blnQuick
   % Parse filename string
   iu=findstr(strName,'_');
   if length(iu)==2
      [iLeft,iRight,strCutoff]=finddelimited('_','_',strName,1);
      blnValid=length(strCutoff)==6 & strcmpi(strCutoff(4),'p') & all(ismember(strCutoff,'p0123456789'));
      if blnValid
         strCutoff=strrep(strCutoff,'p','.');
         fc=sscanf(strCutoff,'%f');
         str=strName(iu(2)+1:end);
      end
   end
end