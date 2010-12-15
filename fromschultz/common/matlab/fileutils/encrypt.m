function encrypt(strFile)

% encrypt - function to encrypt text file (max 245 bytes per line) via RSA
%           into a mat file along same path
%
% INPUTS:
% strFile - string for file
%
% OUTPUTS
% <implicit> mat file (encrypted) along same path as input file
%
% EXAMPLE:
% strFile = 'd:\temp\trash\test.txt';
% encrypt(strFile)
% strMatFile = 'd:\temp\trash\test_encrypted.mat';
% decrypt(strMatFile,'.m')

% Author: Ken Hrovat
% $Id: encrypt.m 4160 2009-12-11 19:10:14Z khrovat $

public_key = [];
fprintf('\nGetting RSA keys...')
[PRIVATE_KEY,public_key] = rsakeys(2048);
fprintf('done.\n')
[strPath, strName, ext, versn] = fileparts(strFile);
enc = [];
fid = fopen(strFile);
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if length(tline) > 245
       fprintf('\nTOO LONG: LINE %s EXCEEDS RSA LIMIT OF 245 BYTES, SO ABORT.\n',tline)
       fclose(fid);
       return
    end
    if ~isempty(tline)
    fprintf('\nWorking on (tline)=(%s)...',tline)
    enc = [enc; rsaenc(tline,PRIVATE_KEY)];
    fprintf('done\n')
    else
    fprintf('\nSkip empty line.\n')        
    end
end
fclose(fid);
strOut = fullfile(strPath,[strName '_encrypted.mat']);
save(strOut,'enc','public_key');
fprintf('\nWrote encrypted mat file %s\n',strOut)