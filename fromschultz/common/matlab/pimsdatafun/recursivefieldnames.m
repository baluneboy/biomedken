function casFields = recursivefieldnames(s)
% recursivefieldnames.m - returns all fieldnames of nested struct
% 
% INPUTS
% s - struct
% 
% OUTPUTS
% casFields - nx1 cell array of strings listing all fields, where nested
%   fields are listed like 'fieldone.fieldtwo' 
% 
% EXAMPLE
% s.one.three='a';
% s.two.three='b';

% Author - Krisanne Litinas
% $Id$

casFields = fieldnames(s);
for fnum = 1:length(casFields)
    if isstruct(s.(casFields{fnum}))
        cn = recursivefieldnames(s.(casFields{fnum}));
        casFields = cat(1, casFields, strcat(casFields(fnum), '.', cn));
    end
end