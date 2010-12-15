function[name] = dbcurr
% dbcurr   Current MySQL database         [mym utilities]
% Example  dbname = dbcurr
if ~myisopen
   error('No MySQL connection active; use ''myopen'' to connect') 
else
   name = char(mym('select database()'));
end   