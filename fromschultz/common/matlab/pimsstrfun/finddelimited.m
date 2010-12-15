function [iLeft,iRight,strDelimited]=finddelimited(strLeft,strRight,str,iStart);

%FINDDELIMITED find string delimited by strLeft & strRight in str starting at index iStart
%
%[iLeft,iRight,strDelimited]=finddelimited(strLeft,strRight,str,iStart);
%
%Inputs: strLeft,strRight - strings for delimiters
%        str - string to inspect
%        iStart - index for starting position
%
%Outputs: iLeft,iRight - start indices of delimiters
%         strDelimited - string (delimited) within str

%Author: Ken Hrovat, 12/13/2000
% $Id: finddelimited.m 4160 2009-12-11 19:10:14Z khrovat $

if iStart>=length(str)
   [iLeft,iRight,strDelimited]=deal([]);
end

iLeft=findstr(str,strLeft);
ind=find(iLeft>=iStart);
if isempty(ind)
   iLeft=[];
   iRight=[];
   strDelimited=[];
   return
else
   iLeft=iLeft(ind(1));
   iRight=findstr(str,strRight);
   ind=find(iRight>iLeft);
   if isempty(ind)
      iRight=[];
      strDelimited=[];
      return
   else
      iRight=iRight(ind(1));
      lenLeft=length(strLeft);
      strDelimited=str(iLeft+lenLeft:iRight-1);
   end
end
