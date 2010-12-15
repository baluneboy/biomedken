function casDirs = dirdrill(strDir);

% function to drill down (recursively) beneath input directory
%            and output cas of subdirectory names (including topmost dir)
%
% INPUTS:
% strDir - string for topmost dir to drill down
%
% OUTPUTS:
% casDirs - cell array of strings for subdir's including topmost
%
% EXAMPLE:
% cas = dirdrill('d:\temp\test_deid')

% Author: Ken Hrovat
% $Id: dirdrill.m 4160 2009-12-11 19:10:14Z khrovat $

casDirs = {};
%fprintf('\nRecursively generating path in prep for drill down...')
strP = genpath(strDir);
%fprintf('done.\n')
r = strP;
while ~isempty(r)
    [tok,r] = strtok(r,';');
    if ~isempty(tok)
        casDirs = [casDirs {tok}];
    end
end