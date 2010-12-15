function[tables] = tblist(varargin)
% tblist   List tables of MySQL database  [mym utilities]
% Inputs   name   - database name, string (optional, current database default) 
% Outputs  tables - table names, (m*1) cell array
% Example  tblist('project')       
if nargin 
   name = varargin{1};
   if ~isdbase(name)
      error('Database %s not found',name)
   end
else
   name = dbcurr; 
   if isempty(name)
       error('No database selected; use ''dbopen'' to open a database')
   end
end   
tables = mym(['show tables in ' name]);
