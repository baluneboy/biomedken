function deletecasfiles(cas)
% deletecasfiles.m - deletes list of files
% 
% INPUTS
% cas - cell array of strings, full filenames of files to be deleted
% 
% OUTPUTS
% [implicit] - files listed in cas will be deleted
% 
% EXAMPLE
% casFiles = {'c:\temp\trash.txt'; 'c:\temp\trash2.txt'};
% deletecasfiles(casFiles)

% Author - Krisanne Litinas
% $Id$

cellfun(@delete,cas,'uni',false)