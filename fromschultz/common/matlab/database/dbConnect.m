% DBCONNECT -- class for connecting and working with a MySQL database.
%
% FUNCTIONS:
% 
% CONSTRUCTOR -- initialize connection
% Inputs:
%   dbname -- name of database to connect to
%   user -- username to connect to database
%   password -- password required to connect to database
%   (OPTIONAL)serveraddr -- machine name or ip where the database is located
%                           If no server address is entered, dbConnect will attempt to connect to local host
%
% Example:
%   conn = dbConnect('daly','myusername','mypassword','Schultz');
%
% ------------------------------------------------------------------------------------------------------------
%
% DBADDROW -- add a row to a table
% Inputs:
%   table -- table name
%   colnames -- CAS of column names in which values will be entered
%   values -- cell array of values corresponding to column names
%             (each cell may be string or numeric based on corresponding
%             column type
%
% Example:
%   conn.dbAddRow('bcisubjects',...
%                 {'subject','grp'},...
%                 {'c9999rand','control'});
%
% ------------------------------------------------------------------------------------------------------------
%
% DBDELETEROW -- delete row(s) from a table
%
% Inputs:
%   table -- name of table from which to delete rows
%   wherevals -- enter column value pairs for
%       where clause to find specific records.  e.g. ('name','Bob','department','sales')
%       to search for multiple values enter the column name
%       followed by a numeric vector or cell array of strings
%       depending on the column type.  e.g. ('department',{'sales',
%       'accounting', 'shipping'})
%
% Example:
%   conn.dbDeleteRow('bcisubject','grp','control','subject',{'c9999
%   rand', 'c9999test'});
%
% ------------------------------------------------------------------------------------------------------------
%
% DBDELETETABLE -- delete table in schema, use with caution
%
% Inputs:
%   table -- table name to delete
%
% Example:
%   conn.dbDeleteTable('tablename');
%
% ------------------------------------------------------------------------------------------------------------
%
% DBUPDATE -- update record(s) within a table
%
% Inputs:
%   table -- name of table where updates will occur
%   changecols -- columns where new values will be placed
%   newvals -- corresponding new values to place in the changed columns
%   wherevals -- enter column value pairs for
%       where clause to find specific records.  e.g. ('name','Bob','department','sales')
%       to search for multiple values enter the column name
%       followed by a numeric vector or cell array of strings
%       depending on the column type.  e.g. ('department',{'sales',
%       'accounting', 'shipping'})
%
% Example:
%   conn.dbUpdate('bcitasks','description','testing update','task',{'wrist_deviation','wrist_extension'});
%   
% ------------------------------------------------------------------------------------------------------------
%
% DBSEARCH -- essentially a select statement in sql.  Search
% through tables for specefic columns and/or values.
%
% Inputs:
%   table -- table name
%   columns -- columns to display in results, enter "[]" for all
%   (OPTIONAL)column value pairs -- enter column value pairs for
%       where clause to find specific records.  e.g. ('name','Bob','department','sales')
%       to search for multiple values enter the column name
%       followed by a numeric vector or cell array of strings
%       depending on the column type.  e.g. ('department',{'sales', 'accounting', 'shipping'})
%
% Outputs:
%   result -- cell array of query results
%
% Example:
%   result = conn.dbSearch('bcisubject',...
%                          {'subject','modality'},...
%                          'grp','control','gender','male'...
%                          'subject_id',[45 32 12]);
%
% ------------------------------------------------------------------------------------------------------------
%
% DBQUERY -- enter a custom sql query to execute
%
% Inputs:
%   query -- your sql query
%
% Outputs:
%
%   result -- returns result if any
%
% Example:
%   query = sprintf(['insert ignore into bcitasks\n'...
%            'set task = ''newtask'',\n'...
%            'description = ''my new task''']);
%   conn.dbQuery(query);
%
% ------------------------------------------------------------------------------------------------------------
%
% DBCLOSE -- close connection to database
%
% Example:
%   conn.dbClose();

% Author: Sahil Grover

classdef dbConnect
    properties (SetAccess = private)
        cid
%         conn
    end %private properties
    
    properties (SetAccess = public)
        resultType
        command
    end %public properties
    
    methods (Access = public)
        function dbConnect_obj = dbConnect(dbname, user, password, varargin)
        % CONSTRUCTOR -- initialize connection
        % Inputs:
        %   dbname -- name of database to connect to
        %   user -- username to connect to database
        %   password -- password required to connect to database
        %   (OPTIONAL)serveraddr -- machine name or ip where the database is located
        %                           If no server address is entered, dbConnect will
        %                           attempt to connect to local host
        % Example:
        %   conn = dbConnect('daly','myusername','mypassword','Schultz');
            if nargin<3
                error('Not enough arguments.');
            end
            if nargin>3 % if server address not specified try local host
                serveraddr = varargin{1};
            else
                serveraddr = 'localhost';
            end
            %setup database connection to mysql
%             driver = 'com.mysql.jdbc.Driver';
%             dburl = sprintf('jdbc:mysql://%s/%s',serveraddr,dbname);
%             dbConnect_obj.conn = database(dbname,user,password,driver,dburl);
            dbConnect_obj.command = '';
            dbConnect_obj.resultType = 'cell';
            dbConnect_obj.cid = mym(-1,'open',serveraddr,user,password);
            mym(dbConnect_obj.cid,'use',dbname);
        end %constructor
    end
    
    methods (Access = private)
        
        function str = strjoin(dbConnect_obj,casVals,varargin)
            [ignore i] = max(size(casVals)); % get largest dimension
            clear ignore
            if i==1
                casVals = casVals'; % reshape if necessary
            end
            % join and delimit strings
            if iscellstr(casVals) && isempty(varargin)
                casVals(2,:) = { ',' };
            else
                for k=1:size(casVals,2)
                    if ischar(casVals{1,k})
                        casVals{2,k} = ',';
                        casVals{1,k} = ['''' casVals{1,k} ''''];
                    elseif ~iscell(casVals{1,k}) && isscalar(casVals{1,k}) && ~isnan(casVals{1,k})
                        casVals{2,k} = ',';
                        casVals{1,k} = num2str(casVals{1,k});
                    elseif ~isnan(casVals{1,k}) && isscalar(casVals{1,k}) && ~isnan(casVals{1,k}{1})
                        casVals{2,k} = ',';
                        casVals{1,k} = num2str(casVals{1,k}{1});
                    else %nan
                        casVals{2,k} = ',';
                        casVals{1,k} = '''null''';
                    end
                end
            end
            str = [ casVals{1:end-1} ];
        end % strjoin
        
        function wherestr = wheregen(dbConnect_obj,wherevals)
        % WHEREGEN -- generate where clause
            if mod(length(wherevals),2)~=0
                error('To specify column values, there must be a value for each column.');
            end
            % there may be a better more complex way to combine the
            % where values (probably not), but because they can be either a string or
            % numeric, element or vector, i'm going to just loop through for simplicity
            wherestr = '';
            for j=1:2:length(wherevals) %loop through each pair
                col = wherevals{j}; %column name should always be a string
                if ~ischar(wherevals{j+1}) % not a single string

                    if isnumeric(wherevals{j+1}) && length(wherevals{j+1})>1 % numeric array
                        val = wherevals{j+1};
                        tempstr = '';
                        for k=1:length(val) % loop through each and build tempstr
                            tempstr = [tempstr col '=' sprintf('%f',val(k)) ' or '];
                        end
                        tempstr = tempstr(1:end-4); % remove last or
                        wherestr = [wherestr '(' tempstr ') and '];

                    elseif iscell(wherevals{j+1}) && length(wherevals{j+1})>1 % cas
                        val = wherevals{j+1};
                        tempstr = '';
                        for k=1:length(val) % loop through each and build tempstr
                            tempstr = [tempstr col '=''' val{k} ''' or '];
                        end
                        tempstr = tempstr(1:end-4); % remove last or
                        wherestr = [wherestr '(' tempstr ') and '];

                    else % only one numeric value
                        val = sprintf('%f',wherevals{j+1});
                        wherestr = [wherestr col '=' val ' and '];

                    end
                else % one string entered
                    val = wherevals{j+1};
                    wherestr = [wherestr col '=''' val ''' and '];
                end
            end
            wherestr = ['where ' wherestr(1:end-5)];
        end % wheregen
        
        function wherestr = wheregen2(dbConnect_obj,wherecols,wherevals)
        % WHEREGEN2 -- generate where clause for 2 inputs (one for columns,
        % one for values)  I had to rename to wheregen2 because matlab is
        % weak typed and doesn't support overloading
        % methods within the same class and ruined my life.
            wherestr = '';
            for j=1:length(wherevals) %loop through each value
                col = wherecols{j}; %column name should always be a string
                if ~ischar(wherevals{j}) % not a single string

                    if isnumeric(wherevals{j}) && length(wherevals{j})>1 % numeric array
                        val = wherevals{j};
                        tempstr = '';
                        for k=1:length(val) % loop through each and build tempstr
                            tempstr = [tempstr col '=' sprintf('%f',val(k)) ' or '];
                        end
                        tempstr = tempstr(1:end-4); % remove last or
                        wherestr = [wherestr '(' tempstr ') and '];

                    elseif iscell(wherevals{j}) && length(wherevals{j})>1 % cas
                        val = wherevals{j};
                        tempstr = '';
                        for k=1:length(val) % loop through each and build tempstr
                            tempstr = [tempstr col '=''' val{k} ''' or '];
                        end
                        tempstr = tempstr(1:end-4); % remove last or
                        wherestr = [wherestr '(' tempstr ') and '];

                    else % only one numeric value
                        val = sprintf('%f',wherevals{j});
                        wherestr = [wherestr col '=' val ' and '];

                    end
                else % one string entered
                    val = wherevals{j};
                    wherestr = [wherestr col '=''' val ''' and '];
                end
            end
            wherestr = ['where ' wherestr(1:end-5)];
        end % wheregen2
        
        function wherestr = setgen(dbConnect_obj,wherecols,wherevals)
        % WHEREGEN2 -- generate set clause for 2 inputs (one for columns,
        % one for values)  I had to rename to wheregen2 because matlab is
        % weak typed and doesn't support overloading
        % methods within the same class and ruined my life.
            wherestr = '';
            for j=1:length(wherevals) %loop through each value
                col = wherecols{j}; %column name should always be a string
                if ~ischar(wherevals{j}) % not a single string

                    if isnumeric(wherevals{j}) && length(wherevals{j})>1 % numeric array
                        val = wherevals{j};
                        tempstr = '';
                        for k=1:length(val) % loop through each and build tempstr
                            tempstr = [tempstr col '=' sprintf('%f',val(k)) ' or '];
                        end
                        tempstr = tempstr(1:end-4); % remove last or
                        wherestr = [wherestr '(' tempstr ') , '];

                    elseif iscell(wherevals{j}) && length(wherevals{j})>1 % cas
                        val = wherevals{j};
                        tempstr = '';
                        for k=1:length(val) % loop through each and build tempstr
                            tempstr = [tempstr col '=''' val{k} ''' , '];
                        end
                        tempstr = tempstr(1:end-4); % remove last or
                        wherestr = [wherestr '(' tempstr ') , '];

                    else % only one numeric value
                        val = sprintf('%f',wherevals{j});
                        wherestr = [wherestr col '=' val ' , '];

                    end
                else % one string entered
                    val = wherevals{j};
                    wherestr = [wherestr col '=''' val ''' , '];
                end
            end
            wherestr = ['where ' wherestr(1:end-3)];
        end % wheregen2
        
        function result = convertResult(dbConnect_obj,out)
            fnames = fieldnames(out);
            result = cell(length(out.(fnames{1})),length(fnames));
            for i=1:length(fnames)
                val = out.(fnames{i});
                if ~isempty(val)
                    if isnumeric(val)
                        result(:,i) = num2cell(val);
                    elseif iscellstr(val)
                        result(:,i) = val;
                    end
                end
            end
        end
        
    end % private methods
    
    methods (Access = public)
        
        function dbAddRow(dbConnect_obj, table,colnames,values)
        % DBADDROW -- add a row to a table
        %
        % Inputs:
        %   table -- table name
        %   colnames -- CAS of column names in which values will be entered
        %   values -- cell array of values corresponding to column names
        %             (each cell may be string or numeric based on corresponding
        %             column type
        %
        % Example:
        %   conn.dbAddRow('bcisubjects',...
        %                 {'subject','grp'},...
        %                 {'c9999rand','control'});
            if ~iscell(colnames)
                colnames = {colnames};
            end
            if ~iscell(values)
                values = {values};
            end
%             fastinsert(dbConnect_obj.conn,table,colnames,values);

            % build command string
            cmd = ['insert into ' table ' ('];
            strCols = dbConnect_obj.strjoin(colnames);
            cmd = [cmd strCols ') values ('];
            strVals = dbConnect_obj.strjoin(values,1);
            cmd = [cmd strVals ')'];
            dbConnect_obj.command = cmd;
            mym(dbConnect_obj.cid,cmd);
        end %dbAddRow
        
        function dbDeleteRow(dbConnect_obj,table,varargin)
        % DBDELETEROW -- delete row(s) from a table
        %
        % Inputs:
        %   table -- name of table from which to delete rows
        %   wherevals -- enter column value pairs for
        %       where clause to find specific records.  e.g. ('name','Bob','department','sales')
        %       to search for multiple values enter the column name
        %       followed by a numeric vector or cell array of strings
        %       depending on the column type.  e.g. ('department',{'sales',
        %       'accounting', 'shipping'})
        %
        % Example:
        %   conn.dbDeleteRow('bcisubject','grp','control','subject',{'c9999rand', 'c9999test'});
        
            cmd = ['delete from ' table ' ' dbConnect_obj.wheregen(varargin)];
%             exec(dbConnect_obj.conn,cmd);
            dbConnect_obj.command = cmd;
            mym(dbConnect_obj.cid,cmd);
        end %dbDeleteRow
        
        function dbDeleteTable(dbConnect_obj, table)
        % DBDELETETABLE -- delete table in schema, use with caution
        %
        % Inputs:
        %   table -- table name to delete
        %
        % Example:
        %   conn.dbDeleteTable('tablename');
        
%             result = get(fetch(exec(dbConnect_obj.conn,['delete from ' table])),'Data');
            dbConnect_obj.command = ['delete from ' table];
            mym(dbConnect_obj.cid,['delete from ' table]);
        end %dbDeleteRow
        
        function dbUpdate(dbConnect_obj, table,changecols,newvals,varargin)
        % DBUPDATE -- update record(s) within a table
        %
        % Inputs:
        %   table -- name of table where updates will occur
        %   changecols -- columns where new values will be placed
        %   newvals -- corresponding new values to place in the changed columns
        %   wherevals -- enter column value pairs for
        %       where clause to find specific records.  e.g. ('name','Bob','department','sales')
        %       to search for multiple values enter the column name
        %       followed by a numeric vector or cell array of strings
        %       depending on the column type.  e.g. ('department',{'sales',
        %       'accounting', 'shipping'})
        %
        % Example:
        %   conn.dbUpdate('bcitasks','description','testing update','task',{'wrist_deviation','wrist_extension'});
        %   
            wherestr = dbConnect_obj.wheregen(varargin);
            if ~iscell(changecols)
                changecols = {changecols};
            end
            if ~iscell(newvals)
                newvals = {newvals};
            end
%             update(dbConnect_obj.conn,table,changecols,newvals,wherestr);

            % build update string
            cmd = ['update ' table ' set '];
            setstr = dbConnect_obj.setgen(changecols,newvals);
            setstr = setstr(7:end);
            cmd = [cmd setstr ' ' wherestr];
            dbConnect_obj.command = cmd;
            mym(dbConnect_obj.cid,cmd);
            
        end %dbUpdate
        
        function result = dbSearch(dbConnect_obj, table, columns, varargin)
        % DBSEARCH -- essentially a select statement in sql.  Search
        % through tables for specefic columns and/or values.
        %
        % Inputs:
        %   table -- table name
        %   columns -- columns to display in results, enter "[]" for all
        %   (OPTIONAL)column value pairs -- enter column value pairs for
        %       where clause to find specific records.  e.g. ('name','Bob','department','sales')
        %       to search for multiple values enter the column name
        %       followed by a numeric vector or cell array of strings
        %       depending on the column type.  e.g. ('department',{'sales', 'accounting', 'shipping'})
        %
        % Outputs:
        %   result -- cell array of query results
        %
        % Example:
        %   result = conn.dbSearch('bcisubject',...
        %                          {'subject','modality'},...
        %                          'grp','control','gender','male'...
        %                          'subject_id',[45 32 12]);
        
            if ~isempty(columns)
                if ~ischar(columns)
%                     [ignore i] = max(size(columns)); % get largest dimension
%                     clear ignore
%                     if i==1
%                         columns = columns'; % reshape if necessary
%                     end
%                     % join and delimit strings
%                     columns(2,:) = { ',' };
%                     cols = [ columns{1:end-1} ];
                    cols = dbConnect_obj.strjoin(columns);
                else
                    cols = columns;
                end
            else % enter "[]" for columns to get all columns
                cols = '*';
            end
            cmd = sprintf('Select %s from %s', cols, table);
            if ~isempty(varargin) % generate where clause
                wherevals = varargin;
                wherestr = dbConnect_obj.wheregen(wherevals);
                cmd = [cmd ' ' wherestr];
            end
%             result = get(fetch(exec(dbConnect_obj.conn,cmd)),'Data');
            dbConnect_obj.command = cmd;
            out = mym(dbConnect_obj.cid,cmd);
            if strcmp('cell',dbConnect_obj.resultType) && isstruct(out)
                result = dbConnect_obj.convertResult(out);
            else
                result = out;
            end
        end %dbSearch
        
        function result = dbQuery(dbConnect_obj,query)
        % DBQUERY -- enter a custom sql query to execute
        %
        % Inputs:
        %   query -- your sql query
        %
        % Outputs:
        %
        %   result -- returns result if any
        %
        % Example:
        %   query = sprintf(['insert ignore into bcitasks\n'...
        %            'set task = ''newtask'',\n'...
        %            'description = ''my new task''']);
        %   conn.dbQuery(query);
        
%             result = get(fetch(exec(dbConnect_obj.conn,query)),'Data');
            dbConnect_obj.command = query;
            out = mym(dbConnect_obj.cid,query);
            if strcmp('cell',dbConnect_obj.resultType) && isstruct(out)
                result = dbConnect_obj.convertResult(out);
            else
                result = out;
            end
        end %dbQuery
        
%         function dbCommit(dbConnect_obj)
%             commit(dbConnect_obj.conn);
%         end %dbCommit
%         
%         function dbUndo(dbConnect_obj)
%             rollback(dbConnect_obj.conn);
%         end %dbRollback
%         
%         function dbAutoCommit(dbConnect_obj, on_off)
%             if strcmpi(on_off,'on')
%                 set(dbConnect_obj.conn,'AutoCommit','on');
%             elseif strcmpi(on_off,'off')
%                 set(dbConnect_obj.conn,'AutoCommit','off');
%             else
%                 error('Must enter either ''on'' or ''off''');
%             end
%         end %dbAutoCommit
        
        function dbClose(dbConnect_obj)
%             close(dbConnection_obj.conn);
            mym(dbConnect_obj.cid,'close');
        end
        
    end % public methods
end %classdef