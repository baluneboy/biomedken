function casFiles = jnj_rename(strDir)

% %EXAMPLE
% strDir = 'S:\temp\hro\testcrago\Bush';
% casFiles = jnj_rename(strDir)

% get jnjcode from file list/uniqueness
casFiles = dirbs(fullfile(strDir,'*.txt'));

% 
s = strsplit(filesep,casFiles)