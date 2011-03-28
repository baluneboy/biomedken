function count = corr_count(a,b)
numRows = size(a,1);
if size(b,1) ~= numRows
    error('daly:corr:InputSizeMismatch', ...
        'A and B must have the same number of rows.');
end
blnA = isnan(a);
blnB = isnan(b);
count = numRows - sum(or(blnA,blnB));