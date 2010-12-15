function ind = findemptycells(cellArray)
%FINDEMPTYCELLS Return index to empty cells  
ind = find(cellfun('isempty',cellArray)).';