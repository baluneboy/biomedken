function bln = diff(cas)

% Overloaded diff for cas input

% Check input shape
if ~isvector(cas)
    error('cas input must be in "vector" form')
end

% Mimic built-in diff behavior when less than 2 inputs
if numel(cas) < 2
    bln = [];
    return
end

% Recursively compare sequence of string pairs
if numel(cas) == 2
    bln = ~strcmp(cas{1},cas{2});
else
    bln = [~strcmp(cas{1},cas{2}) diff(cas(2:end))];
end