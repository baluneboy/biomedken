function strOut = robozero(strFile,strName)

%
% EXAMPLE
% strFile = 'S:\temp\grover\test\eval\20051123_Wed\one_slot_131705_Nt51.dat';
% strName = 'one_slot_131705_Nt52.dat';
% strOut = robozero(strFile,strName)
% [ind,x,y,vx,vy] = roboread(strFile);
% [ind2,x2,y2,vx2,vy2] = roboread(strOut);
% figure,plot(vx,vy,'b',vx2,vy2,'ro'),title('blue = original, red = "zero"')

% read data
[hdr,data] = roboread_hdr(strFile);

% zero out 4th column (vx)
data(:,4) = zeros(size(data,1),1);

% write file
strOut = fullfile(pwd,strName);
robowrite(strOut,data,hdr);