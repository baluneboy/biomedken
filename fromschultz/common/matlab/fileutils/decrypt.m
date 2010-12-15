function strOut = decrypt(strMatFile,strNewExt)
% try help encrypt
load(strMatFile);
str = '';
for i = 1:size(enc,1)
    str = sprintf('%s%s\n',str,char(rsadec(enc(i,:),public_key)));
end
strOut = strrep(strMatFile,'_encrypted.mat',strNewExt);
fid = fopen(strOut,'w');
fprintf(fid,'%s',str);
fclose(fid);