function strOut = stripext(strIn)

% EXAMPLE
% strIn = 'c:\path\to\filename2.dcm';
% strOut = stripext(strIn)

[pathstr,name,ext,versn] = fileparts(strIn);
strOut = fullfile(pathstr,name);
