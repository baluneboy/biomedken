function sOut = replacecommas(sIn)

% REPLACECOMMAS replace commas
casFields = fieldnames(sIn);

for i=1:length(casFields)
    strField = casFields{i};
    if isstr(sIn.(strField))
        sOut.(strField) = strrep(sIn.(strField),',',';');
    else
        sOut.(strField) = sIn.(strField);
    end
end