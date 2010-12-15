function strOut = replace_nth(str,strOld,strNew,n)

% put good help/comments here
%
% EXAMPLE:
% str = 'c:\temp\trash1.txt';
% strOld = 'BAD';
% strNew = 'okay';
% n = 3;
% replace_nth(str,strOld,strNew,n);

% put error check that strFile exists

% READ ALL FILE AS CHAR [%c?], THEN FINDSTR

% Error checking (n is positive integer)

% Check if file or just a string
if exist(str,'file')
    blnIsFile = 1;
    [strOut,bln] = locReplace(locRead(str),n);
else
    blnIsFile = 0;
    [strOut,bln] = locReplace(str,n);
end

% Protect original file
if blnIsFile
    type(str)
    copyfile(str,[str '.old']);
    fid = fopen(strFile,'w');
    fprintf(fid,'%s',str);
    fclose(fid);
    type(str)
end

% ---------------------------
function c = locRead(strFile)
% Read entire file [yikes if it's a biggie]
fid = fopen(strFile,'r');
c = fscanf(fid,'%c');
fclose(fid);

% --------------------------------------------
function [str,blnDidReplace] = locReplace(c,n)

blnDidReplace = 0;

% Find old string
iOld = findstr(c,strOld);

% If nothing found (or fewer than n found), then done
if isempty(iOld) || length(iOld)<n
    str = c;
    return
end

% Get string before/after the find
ind = iOld(n);
strLeft = c(1:ind-1);
cmax = min([length(c) ind+length(strOld)]);
strRight = c(cmax:end);

% Replace
str = [strLeft strNew strRight];
blnDidReplace = 1;