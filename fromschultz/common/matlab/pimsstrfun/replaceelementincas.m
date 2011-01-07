function casNew = replaceelementincas(casOld,casInsert,iInsert)
% EXAMPLE
% casOld = {'a'; 'b'; 'c'; 'd'; 'e'};
% casInsert = {'b'; 'b'};
% iInsert = 2;
% casNew = replaceelementincas(casOld,casInsert,iInsert)

casBefore = casOld(1:iInsert-1);
casAfter = casOld(iInsert+1:end);
casNew = [casBefore; casInsert; casAfter];