function cas = simpleglob(strPathPattern)

% GLOB   Filename expansion/search via wildcards.
%
% EXAMPLE
% strPathPattern = 'c:\temp\*\*ash*.txt';
% cas = simpleglob(strPathPattern)

% strPathPattern = forwardslash(strPathPattern); % for usage on stroke-eeg
if exist('c:\_workcopy\scripts\trunk','dir')
    strCmd = ['c:\_workcopy\scripts\trunk\python\fileglobber_project\simpleglob.py "' strPathPattern '"'];
else
    strCmd = ['c:\_workcopy\scripts\python\fileglobber_project\simpleglob.py "' strPathPattern '"'];
end
[foo,casTwo] = dos(strCmd);
cas = strsplit(10,casTwo)';
indToss = findemptycells(cas);
cas(indToss) = [];