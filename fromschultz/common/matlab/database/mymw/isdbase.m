function[i] = isdbase(name)
% isdbase  True if MySQL database exists  [mym utilities]
% Example  if isdbase('junk'), dbdrop('junk'), end
if ~myisopen
   error('No MySQL connection active; use ''myopen'' to connect')
else
   i = any(strcmp(name,mym('show databases')));
end   
