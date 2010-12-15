function r = executemysqlquery(strQuery)
% executemysqlquery.m - executes given MYSQL-syntax query and returns result
% 
% INPUTS
% strQuery - string, MYSQL syntax - query to be executed
% 
% OUTPUTS
% r - struct, result of query.  
% 
% EXAMPLE
% strQuery = 'select * from gaitviconsession where subject = "c1708cogp" and session = "pre"';
% r = executemysqlquery(strQuery)

% Author - Krisanne Litinas
% $Id$

% Establish connection
mym('open', 'schultz', 'klitinas', 'mpw4mysql');
mym('use','daly');

% Execute query
r = mym(strQuery);

% Close connection
mym('close');