function strOut = forwardslash(strIn)
% EXAMPLE
% forwardslash('c:\temp\trash.txt')
strOut = strrep(strIn,filesep,'/');