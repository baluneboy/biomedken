function casNew = sortnexusfiles(cas)
% EXAMPLE
% casNew = sortnexusfiles(cas)

stringLengths = cellfun(@length,cas);


if isempty(diff(stringLengths)) % no real sorting to do so end here
    casNew = cas;
else % sort
    iMaxLength = stringLengths == max(stringLengths);
    casLong = cas(iMaxLength);
    cas(iMaxLength) = [];
    casNew = [cas; casLong];
end



