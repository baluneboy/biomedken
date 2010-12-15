function cUnnest = unnestcell(cNested)
% unnestcell - unnest a nested cell array
% 
% INPUTS
% cNested - cell array that is nested
% 
% OUTPUTS
% cUnnested - unnested cell array, size 1xnumel(cNested)
% 
% EXAMPLE
% c = {{'one'};{'two'}};
% cUnnest = unnestcell(c)

cUnnest = [cNested{:}];