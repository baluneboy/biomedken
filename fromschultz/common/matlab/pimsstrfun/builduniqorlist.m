function str = builduniqorlist(cas)

% EXAMPLE
% cas = {'four','one','two','three','two','three','one'}
% str = builduniqorlist(cas)

%% Get unique ones
u = unique(cas);

%% Concatenate with the "or" symbol
str = strjoin(u,'|');