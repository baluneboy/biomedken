function everyntix(hax,n);

xlab=cellstr(get(hax,'xticklabel'));
cas=cellstr(repmat(' ',length(xlab),1));
for i=1:n:length(xlab)
   cas{i}=xlab{i};
end

set(hax,'xticklabel',cas);


