function out = condensetworows(x,row1)
row2 = row1+1;
if nRows(x)<row2
    out = x;
    return
end
a = x(row1,1); b = x(row1,2);
c = x(row2,1); d = x(row2,2);
if c <= b
    x(row1,1) = a; x(row1,2) = d;
    x(row2,:) = [];
end
out = x;