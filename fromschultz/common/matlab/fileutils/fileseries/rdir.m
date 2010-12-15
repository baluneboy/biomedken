function fo=rdir(name,opt)
%RDIR Recursive list directory.
%   F = RDIR(NAME) returns a cell array of file names matching NAME.
%   NAME may be a cell array of strings, and may contain cascading
%   pathnames separated by '/' followed by a filename. Wildcards may be
%   used both in the final filename, as in DIR, but also in the
%   intermediate pathnames. For example, F=RDIR('mydir*/*.m') returns all
%   the M-Files contained in each directory that begins with 'mydir'.
%   In addition, brackets [] may also be used (see EXPANDSTR), both in the
%   pathnames and in the filename. If wildcards or brackets are present in
%   the pathnames, RDIR lists recursively all the directories matching the
%   pathnames.
%
%   RDIR file_name  or  RDIR('file_name') displays the result.
%
%   F = RDIR(NAME,'fileonly') only returns file names (by default).
%   F = RDIR(NAME,'dironly') only returns directory names, but does not
%   list their content.
%   F = RDIR(NAME,'filedir') returns both files and directories (as DIR).
%   (Note that, when options 'dironly' or 'filedir' are used, the
%   fictitious directories '.' (current) and '..' (parent) are not
%   returned, contrarily to DIR).
%
%   Examples:
%
%     F = RDIR('set*/B[1:8,2].v*')  returns the file names matching
%     'B01.v*' to 'B08.*' in each directory matching 'set*'.
%
%     F = RDIR('set[1 2 3]*/*/B01.vec')  returns the file name 'B01.vec',
%     if present, in all the subdirectories of each directory matching
%     'set1*', 'set2*', 'set3*'.
%
%   See also EXPANDSTR, DIR.


%   F. Moisy, moisy_at_fast.u-psud.fr
%   Revision: 1.00,  Date: 2005/10/04


% History:
% 2004/10/04: v1.00, first version.

error(nargchk(1,2,nargin));

verb=0; % set verb=1 for debugging (verbose), or verb=0 for normal use.

if nargin==1, opt='fileonly'; end;

if iscell(name),
    f={};
    for i=1:length(name),
        if verb, disp(['im in ' pwd ' and im calling rdir for ' name{i}]); end;
        ff=rdir(name{i},opt);
        f={f{:} ff{:}};
    end;
else
    % search for '/' or '\':
    p=findstr(name,'/');
    if ~length(p), p=findstr(name,'/'); end;
    
    if ~length(p)
        if verb, disp(['im in ' pwd ', with ' name ' that contains no /']); end;
        % if the input string contains no '/'
        name=expandstr(name); % tries to expand the file name
        if ~iscell(name), % if there were nothing to expand
            % then simply returns the filenames matching NAME:
            if verb, disp(['im in ' pwd ' and im going to call dir for ' name]); end;
            f=dir(name);
            switch lower(opt)
                case 'fileonly', f=f(~[f.isdir]);
                case 'dironly', f=f([f.isdir]);
                case {'filedir','dirfile'}, %f=f;
                otherwise, error(['Unknown option ''' opt '''']);
            end;
            f={f.name};
            ff={};
            for i=1:length(f),
                if ((~strcmp(f{i},'..')) && (~strcmp(f{i},'.'))), % excludes '.' and '..'
                    ff={ff{:} f{i}};
                end;
            end;
            f=ff;
        else
            % something has been expanded, so calls rdir for each file name
            f={};
            for i=1:length(name),
                if verb, disp(['im in ' pwd ' and im going to call rdir for ' name{i}]); end;
                ff=rdir(name{i},opt);
                for j=1:length(ff),
                    %f={f{:} [name{i} '/' ff{j}]};
                    f={f{:} ff{j}};
                end;
            end;
        end;
    else
        if verb, disp(['im in ' pwd ', with ' name ' that contains /(s)']); end;
        pname=name(1:(p-1)); % first pathname of the input string
        fname=name((p+1):end); % next pathnames and final filename
        pname=expandstr(pname); % tries to expand the first path name
        if verb, disp(['pname=' pname ',  fname=' fname]); end;
        if ~iscell(pname), % if there were nothing to expand,
            if ~length(findstr(pname,'*'))
                if verb, disp([pname ' contains no *']); end;
                if exist(pname,'dir')
                    d={pname};
                else
                    d={};
                end;
            else
                if verb, disp([pname ' contains *(s)']); end;
                d=dir(pname); % looks for pathnames matching the first pathname
                d=d([d.isdir]); % keeps only directories
                d={d.name}; % extracts the names
            end;
            f={};
            for i=1:length(d),
                if ((~strcmp(d{i},'..')) && (~strcmp(d{i},'.'))), % excludes '.' and '..'
                    if verb, disp(['im in ' pwd ', and im entering in ' d{i}]); end;
                    cd(d{i}),
                    % calls (possibly recursively) rdir for the next pathnames:
                    if verb, disp(['im in ' pwd ' and im calling rdir for ' fname]); end;
                    ff=rdir(fname,opt);
                    % builds the output cell array:
                    for j=1:length(ff),
                        f={f{:} [d{i} '/' ff{j}]};
                    end;
                    cd ..
                end;
            end;
        else
            % if pname has been expanded, then calls rdir for each pathname
            f={};
            for i=1:length(pname),
                ff=rdir([pname{i} '/' fname],opt);
                f={f{:} ff{:}};
            end;
        end;
    end;
end;

if nargout==0
    disp(f');
else
    fo=f;
end;
