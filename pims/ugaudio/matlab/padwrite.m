function padwrite(data, strFile)

% EXAMPLE
% fs = 44100; % CD quality audio
% t = 0:1/fs:1-(1/fs);
% Az = 10;  z = Az*chirp(t, 200, 0.9, 2000);
% Ay = 2; y = Ay*square(2*pi*100*t);
% Ax = 5;   x = Ax*ones(size(z));
% data = [t(:) x(:) y(:) z(:)];
% strFile = '/tmp/test2.pad';
% padwrite(data, strFile);

%Author: Ken Hrovat, 10/29/14
%$Id$

% Write pad file
fid = fopen(strFile,'w','l');
count = fwrite(fid,data','float');
fclose(fid);

fprintf('\nWrote %d records to PAD file %s', count, strFile)