function cStrout=topappend(cAdd,cStrings);

%TOPAPPEND [obsolete, see cappend] top append string (or cArray of strings) on cStrings
%
%Inputs: cAdd - string or cell array of strings to top append
%        cStrings - cell array of strings (or empty)
%
%Output: cStrout - cell array of appended strings

%written by: Ken Hrovat on 4/26/00
% $Id: topappend.m 4160 2009-12-11 19:10:14Z khrovat $

if isstr(cAdd)
   cTmp{1,1}=cAdd;
   cAdd=cTmp;
end

cStrout={};
if isempty(cStrings)
   cStrout=cAdd;
   return
else
   sizeIn=size(cStrings);
   if min(sizeIn)~=1
      error('cStrings must be a "vector" cell array')
   end
   if sizeIn(1)==1
      cStrings=cStrings';
   end   
   [cStrout{size(cAdd,1)+1:size(cAdd,1)+size(cStrings,1),1}]=deal(cStrings{:});
   [cStrout{1:size(cAdd,1),1}]=deal(cAdd{:});
end
