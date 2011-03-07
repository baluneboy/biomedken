function si = structparse(s,i)
% structparse - given structure, returns new structure with field values at desired index
% 
% INPUTS
% s - structure (note: this hasn't been tested for structures with length > 1)
% i - double, desired index.  Must not be greater than shortest field in s.
% 
% OUTPUTS
% si - structure with fields of fieldnames(s) containing value in s of each
% field at index i
% 
% EXAMPLE
% s.nums = [1 2 3 4];
% s.words = {'one' 'two' 'three' 'four'};
% sTwo = structparse(s,2)

% Author - Krisanne Litinas
% $Id$

si = structfun(@(x) (x(i)),s,'UniformOutput',false);