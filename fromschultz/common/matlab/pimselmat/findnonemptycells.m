function ind = findnonemptycells(cellArray)
%FINDNONEMPTYCELLS Return index to non-empty cells  
ind = find(~cellfun('isempty',cellArray)).';