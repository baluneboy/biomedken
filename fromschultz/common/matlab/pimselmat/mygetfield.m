function out = mygetfield(s,strField)
[c{1:length(s)}] = deal(s.(strField));
out=cell2mat(c);