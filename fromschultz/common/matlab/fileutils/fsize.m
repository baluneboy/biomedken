function bytes = fsize(filestring)
% bytes = fsize(filestring)
%
%       Input:  filestring -- string denoting filename
%
%       Output: returns the size of filestring in bytes

% written by: Ken Hrovat on 2/9/95
% $Id: fsize.m 4160 2009-12-11 19:10:14Z khrovat $

fid=fopen(filestring, 'r');
if (fid==-1)
        error('fsize: CANNOT OPEN FILE TO DETERMINE SIZE')
end

fseek(fid, -1, 'eof');
bytes = ftell(fid) + 1;
fclose(fid);

