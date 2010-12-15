function cOut=cappend(cStrings,cAdd);

%CAPPEND smartly prepend or append string (or cArray of strings) on cStrings
%
%cOut=cappend(cStrings,cAdd);
%
%Inputs: cStrings - cell array of strings (or empty)
%        cAdd - string or cell array of strings to top append
%
%Output: cOut - cell array of appended strings

%written by: Ken Hrovat on 4/26/00
% $Id: cappend.m 4160 2009-12-11 19:10:14Z khrovat $

if isstr(cStrings) & ~isempty(cStrings)
   cStrings=cellstr(cStrings);
end
if isstr(cAdd) & ~isempty(cAdd)
   cAdd=cellstr(cAdd);
end

cOut={};
if isempty(cStrings)
   cOut=cAdd;
   return
elseif isempty(cAdd)
   cOut=cStrings;
   return
else
   sizeIn=size(cStrings);
   if min(sizeIn)~=1
      error('cStrings must be a "vector" cell array')
   end
   if sizeIn(1)==1
      cStrings=cStrings';
   end
   sizeA=size(cAdd);
   if min(sizeA)~=1
      error('cAdd must be a "vector" cell array')
   end
   if sizeA(1)==1
      cAdd=cAdd';
   end     
   [cOut{1:size(cStrings,1),1}]=deal(cStrings{:});
   [cOut{size(cStrings,1)+1:size(cAdd,1)+size(cStrings,1),1}]=deal(cAdd{:});
end
