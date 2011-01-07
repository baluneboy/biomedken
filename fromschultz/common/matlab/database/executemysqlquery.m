function r = executemysqlquery(strQuery,strSchema)
% executemysqlquery.m - executes given MYSQL-syntax query and returns result
% 
% INPUTS
% strQuery - string, MYSQL syntax - query to be executed
% strSchema - string, schema to look for table (default is 'daly')
% 
% OUTPUTS
% r - struct, result of query.  
% 
% EXAMPLE
% strQuery = 'select * from gaitviconsession where subject = "c1708cogp" and session = "pre"';
% r = executemysqlquery(strQuery)

% Author - Krisanne Litinas
% $Id$

if nargin == 1
    strSchema = 'daly';
end

% Establish connection
foo = mym('open', 'schultz', 'klitinas', 'mpw4mysql'); %#ok<NASGU>
foo = mym('use',strSchema); %#ok<NASGU>

% Execute query
r = mym(strQuery);

% Close connection
mym('close');