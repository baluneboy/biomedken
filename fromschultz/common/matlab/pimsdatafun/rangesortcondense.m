function out = rangesortcondense(in)

% in = indRange
% out = indRangeSortCondense
%
% EXAMPLE
% in = [1 3; 7 11; 2 4]
% rangesortcondense(in)

%% Verify 2 columns (for ranges along the rows)
if nCols(in)~=2
   error('daly:common:badInput','number of columns for range input must be 2 (not %d)',nCols(in)) 
end

%% Verify diff (col2 - col1) is positive (right range up)
if min(diff(in,1,2))<0
    error('daly:common:badInput','column 2 values must be greater than or equal to column 1 values for range goodness') 
end

%% Sort based on lower limit of each range (first column)
[s,i] = sortrows(in,1);


s
out = []