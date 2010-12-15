function strOut=deblankboth(strIn)

%DEBLANKBOTH remove leading and trailing blanks from strIn
%
%strOut=deblankboth(strIn);
%
%Input: strIn - string to remove blanks from
%
%Output strOut - string without leading or trailing blanks
%
%see: deblank.m

if ~isstr(strIn)
   error('input not a string')
end

strFwd=deblank(strIn);
strBwd=fliplr(strFwd(:)');
strDBwd=deblank(strBwd);
strOut=fliplr(strDBwd(:)');