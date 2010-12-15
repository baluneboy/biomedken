function[names] = dblist
% dblist   List MySQL databases           [mym utilities]
% Example  dbs = dblist
if ~myisopen
   error('No MySQL connection active; use ''myopen'' to connect')
else
   names = mym('show databases');
end   
