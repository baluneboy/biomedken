function str = casjoin(strJoin, cas)

% CASJOIN [this code is obsolete or needs rewrite to tap into cellfun]
str = '';
for i = 1:length(cas)-1
    str = [str cas{i} strJoin];
end
str = [str cas{end}];